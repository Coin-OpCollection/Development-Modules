"""
Runs the capcom_dl0921 system testbench on the module's netlist: compiles hdl/netlist/ with the CPS-A-01
(DL-0311) netlist of the capcom_dl0311 module beside this one and the board model, runs the frame standard
(frames.txt: one gameplay frame for each supported romset), and renders and scores every frame against its reference.
Each set's frame state is made from the user's own romsets and MAME.

    python sim/scripts/run_tb.py --roms <romsets> --mame <MAME>   prepare, compile, run, render and score
    python sim/scripts/run_tb.py --prepare --roms ... --mame ...   the frame states only
    python sim/scripts/run_tb.py --compile                         compile, then elaborate the testbench and the
                                                                   wrapper (with hdl/)
    python sim/scripts/run_tb.py --post                            render and score the existing captures again
    python sim/scripts/run_tb.py --only sf2hf sf2ua                any supported sets
    python sim/scripts/run_tb.py --jobs 16                         16 at a time (default)

The romset folder holds MAME's merged romsets, a clone's files in its parent's zip (more than one folder separated by
semicolons); CPS1_ROMS and MAME_EXE stand in for --roms and --mame. A frame state is made once and kept. ModelSim from
the PATH, or from the folder MODELSIM names; Python 3 with Pillow.

The frame state of each set, in sim/output/frames/<set>/state/:
    <set>_gfx.bin               the graphics ROM image, from the romset zip (build_gfxrom.py)
    <set>_f<frame>_*.bin        GFX RAM and the CPS-A and CPS-B registers at the frame, from MAME (dump_frames.lua)
    <set>_<frame>_mame.png      MAME's snapshot of the frame, turned to the chip's orientation for the vertical games
    ref_f<frame>_*              the reference render of the frame state (ref_render.py)
    mapper.txt                  the set's graphics mapper (games.py)
    mame.log                    MAME's output

Outputs in sim/output/:
    work/, work_synth/          the ModelSim libraries
    frames/summary.txt          the scores of every run
    frames/results.txt          each run's PASS / FAIL and the totals
    frames/<set>/               one folder per romset
        <set>_<frame>.png       the frame
        capture/                the LUTA, palette and frame buffer captures
        compare/                the frame beside MAME's snapshot
        diff/                   the LUTA misses per layer
        prio/                   the composite misses, when there are any
        log/                    the simulation log
        state/                  the frame state
"""
import argparse
import concurrent.futures
import os
import re
import shutil
import subprocess
import sys
import time

from PIL import Image

import games

HERE = os.path.dirname(os.path.abspath(__file__))
SIM = os.path.dirname(HERE)
MOD = os.path.dirname(SIM)
NAME = 'capcom_dl0921'
WRAPPER = 'capcom_cps_b_21'
OTHER = 'capcom_dl0311'
OTHER_NL = os.path.join(os.path.dirname(MOD), OTHER, 'hdl', 'netlist')
MSIM = os.environ.get('MODELSIM', '')
OUT = os.path.join(SIM, 'output')
WORK = os.path.join(OUT, 'work')
WORK_SYN = os.path.join(OUT, 'work_synth')
FRAMES = os.path.join(OUT, 'frames')
ENV = dict(os.environ, PYTHONDONTWRITEBYTECODE='1')
KINDS = ('capture', 'compare', 'diff', 'prio', 'log', 'state')


def load_runs():
    """(set, parent or '', frame) for every set of the frame standard (frames.txt)"""
    runs = []
    for line in open(os.path.join(HERE, 'frames.txt')):
        if line.strip() and not line.startswith('#'):
            g, parent, f = line.split()
            runs.append((g, '' if parent == '-' else parent, int(f)))
    return runs


RUNS = load_runs()


def fwd(path):
    return path.replace('\\', '/')


def base(run):
    return '%s_%d' % (run[0], run[2])


def gdir(run):
    return os.path.join(FRAMES, run[0])


def sdir(run):
    return os.path.join(FRAMES, run[0], 'state')


def dump(run):
    return os.path.join(sdir(run), '%s_f%05d' % (run[0], run[2]))


def ref(run):
    return os.path.join(sdir(run), 'ref_f%05d' % run[2])


def gfx(run):
    return os.path.join(sdir(run), run[0] + '_gfx.bin')


def snap(run):
    return os.path.join(sdir(run), '%s_mame.png' % base(run))


def ms(tool):
    return os.path.join(MSIM, tool) if MSIM else tool


def modelsim(*args):
    r = subprocess.run([ms(args[0])] + list(args[1:]), capture_output=True, text=True)
    if r.returncode:
        sys.exit('%s failed\n%s%s' % (args[0], r.stdout, r.stderr))


def tool(script, *args):
    return subprocess.run([sys.executable, os.path.join(HERE, script)] + list(args), cwd=HERE, capture_output=True,
                          text=True, env=ENV)


def romset(roms, run):
    """the set's own zip or, for a clone, its parent's merged zip"""
    for d in roms:
        for n in (run[0], run[1]):
            if n and os.path.exists(os.path.join(d, n + '.zip')):
                return os.path.join(d, n + '.zip')
    return None


def prepare_one(run, roms, mame):
    """the set's frame state: what is there already is kept"""
    s = sdir(run)
    os.makedirs(s, exist_ok=True)
    if not os.path.exists(gfx(run)):
        z = romset(roms, run)
        if not z:
            return '%s: no %s.zip%s in %s' % (run[0], run[0], ' or %s.zip' % run[1] if run[1] else '', ';'.join(roms))
        r = tool('build_gfxrom.py', run[0], z, gfx(run))
        if r.returncode:
            return '%s: build_gfxrom.py failed\n%s' % (run[0], r.stderr)
    if not all(os.path.exists(dump(run) + k) for k in ('_gfxram.bin', '_cpsa.bin', '_cpsb.bin')) or \
            not os.path.exists(snap(run)):
        # MAME on its default settings: no ini read, its configuration, NVRAM and snapshot in a folder of its own
        m = os.path.join(s, 'mame')
        if os.path.isdir(m):
            shutil.rmtree(m)
        os.makedirs(m)
        env = dict(ENV, CPS1DUMP_OUT=fwd(s), CPS1DUMP_FRAMES=str(run[2]))
        r = subprocess.run([mame, run[0], '-rompath', ';'.join(roms), '-noreadconfig', '-skip_gameinfo',
                            '-nothrottle', '-sound', 'none', '-video', 'none',
                            '-seconds_to_run', str(run[2] // 60 + 60),
                            '-cfg_directory', fwd(os.path.join(m, 'cfg')),
                            '-nvram_directory', fwd(os.path.join(m, 'nvram')),
                            '-snapshot_directory', fwd(m), '-snapname', 'snap',
                            '-autoboot_script', fwd(os.path.join(HERE, 'dump_frames.lua'))],
                           cwd=m, env=env, capture_output=True, text=True)
        open(os.path.join(s, 'mame.log'), 'w').write(r.stdout + r.stderr)
        shot = os.path.join(m, 'snap.png')
        if not os.path.exists(shot) or not os.path.exists(dump(run) + '_cpsb.bin'):
            return '%s: MAME made no frame state for frame %d (see %s)' % (run[0], run[2],
                                                                          os.path.join(s, 'mame.log'))
        im = Image.open(shot)
        if im.size[1] > im.size[0]:             # MAME saves the vertical games upright; the chip draws them on 384 x 224
            im = im.transpose(Image.ROTATE_270)
        im.save(snap(run))
        im.close()
        shutil.rmtree(m)
    if not os.path.exists(ref(run) + '_luta.txt'):
        r = tool('ref_render.py', dump(run), gfx(run), run[0], ref(run))
        if r.returncode:
            return '%s: ref_render.py failed\n%s' % (run[0], r.stderr)
    return None


def prepare(runs, roms, mame, jobs):
    need = [r for r in runs if not (os.path.exists(gfx(r)) and os.path.exists(snap(r)) and
                                    os.path.exists(ref(r) + '_luta.txt'))]
    if not need:
        return
    # the romsets and MAME are needed for a missing graphics ROM image, dump or snapshot; the reference render is not
    if [r for r in need if not (os.path.exists(gfx(r)) and os.path.exists(snap(r)))] and (not roms or not mame):
        sys.exit('%d sets have no frame state yet: --roms and --mame (or CPS1_ROMS and MAME_EXE) are needed'
                 % len(need))
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        errors = [e for e in ex.map(lambda r: prepare_one(r, roms, mame), need) if e]
    if errors:
        sys.exit('\n'.join(errors))


def compile_all():
    other = [os.path.join(OTHER_NL, OTHER + f) for f in ('_cells.v', '.v')]
    if not all(os.path.exists(f) for f in other):
        sys.exit('the testbench takes the %s netlist from %s, which is not there' % (OTHER, fwd(OTHER_NL)))
    for w in (WORK, WORK_SYN):
        if os.path.isdir(w):
            shutil.rmtree(w)
    os.makedirs(OUT, exist_ok=True)
    modelsim('vlib', fwd(WORK))
    mod = [os.path.join(MOD, f) for f in ('hdl/netlist/%s_cells.v' % NAME, 'hdl/netlist/%s.v' % NAME,
                                          'sim/hitachi_hm53461.v', 'sim/tb_%s.v' % NAME)]
    modelsim('vlog', '-quiet', '-work', fwd(WORK), *[fwd(f) for f in other + mod])
    modelsim('vopt', '-quiet', '-work', fwd(WORK), '+acc', 'tb_' + NAME, '-o', 'tb_opt')
    # the wrapper takes the synchronous netlist, which shares the netlist's module names: a library of its own
    modelsim('vlib', fwd(WORK_SYN))
    syn = [fwd(os.path.join(MOD, f)) for f in ('hdl/%s_cells.v' % NAME, 'hdl/%s.v' % NAME, WRAPPER + '.v')]
    modelsim('vlog', '-quiet', '-work', fwd(WORK_SYN), '+define+SIMULATION', *syn)
    modelsim('vopt', '-quiet', '-work', fwd(WORK_SYN), WRAPPER, '-o', 'wrapper_opt')


def run_frames(runs, jobs):
    procs = []
    for run in runs:
        while len([p for p in procs if p.poll() is None]) >= jobs:
            time.sleep(1)
        b, g = base(run), gdir(run)
        for kind in KINDS:
            os.makedirs(os.path.join(g, kind), exist_ok=True)
            if kind != 'state':
                for f in os.listdir(os.path.join(g, kind)):
                    if f.startswith(b):
                        os.remove(os.path.join(g, kind, f))
        cmd = [ms('vsim'), '-c', '-lib', fwd(WORK), '-l', fwd(os.path.join(g, 'log', b + '.log')), 'tb_opt',
               '+frames=4', '+fbdump'] + games.plusargs(run[0], fwd(os.path.join(sdir(run), 'mapper.txt'))) + [
              '+game=' + run[0], '+dump=' + fwd(dump(run)), '+gfx=' + fwd(gfx(run)),
              '+out=' + fwd(os.path.join(g, 'capture', b)), '-do', 'run -all; quit -f']
        procs.append(subprocess.Popen(cmd, cwd=os.path.join(g, 'log'), stdout=subprocess.DEVNULL,
                                      stderr=subprocess.DEVNULL))
    for p in procs:
        p.wait()


def lead(text):
    m = re.match(r'[+-]?\d+', text)
    return int(m.group(0)) if m else 0


def post_one(run):
    b, g = base(run), gdir(run)
    log = os.path.join(g, 'log', b + '.log')
    if not os.path.exists(log) or 'FI #5' not in open(log, errors='replace').read():
        return ['== ' + b, 'did not finish']
    cap = fwd(os.path.join(g, 'capture', b))
    png = fwd(os.path.join(g, b + '.png'))
    diff = fwd(os.path.join(g, 'diff', b + '.png'))
    tool('render_cap.py', cap, '4', png)
    tool('compare.py', fwd(snap(run)), png, fwd(os.path.join(g, 'compare', b + '.png')))
    lines = ['== ' + b]
    lines += [l for l in tool('luta_diff.py', cap, '4', fwd(ref(run)), diff).stdout.splitlines() if l != diff]
    pages = tool('pal_check.py', cap, '5', fwd(dump(run)), run[0], fwd(gfx(run))).stdout.splitlines()[:6]
    lines.append('palette %d / 3072' % sum(lead(l.split()[2]) if len(l.split()) > 2 else 0 for l in pages))
    lines += tool('prio_check.py', cap, '4', fwd(dump(run)), fwd(ref(run)), run[0],
                  fwd(os.path.join(g, 'prio', b + '.png')), '--summary').stdout.splitlines()
    prio = os.path.join(g, 'prio')
    if os.path.isdir(prio) and not os.listdir(prio):
        os.rmdir(prio)
    return lines


def blocks(path):
    res, cur = {}, None
    for l in open(path).read().splitlines():
        if l.startswith('== '):
            cur = l[3:]
            res[cur] = []
        elif cur:
            res[cur].append(l)
    return res


def post(runs, jobs):
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
        results = list(ex.map(post_one, runs))
    # a partial run replaces its own runs' scores and keeps the others, in the frame standard's order
    path = os.path.join(FRAMES, 'summary.txt')
    scores = blocks(path) if os.path.exists(path) else {}
    scores.update((r[0][3:], r[1:]) for r in results)
    open(path, 'w').write(''.join('== %s\n' % b + ''.join(l + '\n' for l in scores[b])
                                  for b in (base(r) for r in RUNS) if b in scores))
    bad = [r[0][3:] for r in results if r[1:] == ['did not finish']]
    if bad:
        sys.exit('did not finish: ' + ' '.join(bad))


LAYER = re.compile(r'(\w+)\s+sim pixels\s+(\d+)\s+ref pixels\s+\d+\s+offset \((-?\d+), (-?\d+)\)\s+'
                   r'exact LUTA matches\s+(\d+)(?:\s+without blink step\s+(\d+))?')


def results(runs):
    """each run's PASS / FAIL from its scores (every layer's pixels exact at offset (0, 0), the stars apart from their
    blink step; the palette; the composite), into frames/results.txt and printed with the totals"""
    scores = blocks(os.path.join(FRAMES, 'summary.txt'))
    text, failed = [], []
    for run in runs:
        b = base(run)
        layers, ok, pal, comp = [], b in scores, '-', '-'
        for l in scores.get(b, []):
            m = LAYER.match(l)
            if m:
                name, sim, dx, dy, exact, blink = m.groups()
                ok &= (dx, dy) == ('0', '0') and int(blink or exact) == int(sim)
                layers.append('%s %s' % (name, sim))
            elif l.startswith('palette') or l.startswith('composite'):
                w = l.split()
                ok &= w[1] == w[3]
                if w[0] == 'palette':
                    pal = ' '.join(w[1:4])
                else:
                    comp = ' '.join(w[1:4])
        if not ok:
            failed.append(b)
        text.append('%s: %s: pixels exact, %s; palette %s; composite %s' %
                    ('PASS' if ok else 'FAIL', b, ', '.join(layers), pal, comp))
    bar = '=' * 57
    text += ['', bar, '  tb_%s results: %d / %d passed (%d failed)' % (NAME, len(runs) - len(failed), len(runs),
                                                                       len(failed)), bar,
             '  ALL TESTS PASSED' if not failed else '  FAILED: ' + ' '.join(failed)]
    open(os.path.join(FRAMES, 'results.txt'), 'w').write('\n'.join(text) + '\n')
    print('\n'.join(text))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--roms', default=os.environ.get('CPS1_ROMS', ''))
    ap.add_argument('--mame', default=os.environ.get('MAME_EXE', ''))
    ap.add_argument('--prepare', action='store_true')
    ap.add_argument('--compile', action='store_true')
    ap.add_argument('--post', action='store_true')
    ap.add_argument('--only', nargs='*')
    ap.add_argument('--jobs', type=int, default=16)
    a = ap.parse_args()
    runs = [r for r in RUNS if not a.only or r[0] in a.only]
    if a.compile:
        compile_all()
        print('compiled; tb_%s and %s elaborate' % (NAME, WRAPPER))
        sys.exit(0)
    if not a.post:
        prepare(runs, [d for d in a.roms.split(';') if d], a.mame, a.jobs)
        if a.prepare:
            print('frame states ready: %d sets' % len(runs))
            sys.exit(0)
        compile_all()
        run_frames(runs, a.jobs)
    post(runs, a.jobs)
    results(runs)
