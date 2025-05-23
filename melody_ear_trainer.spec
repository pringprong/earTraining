# -*- mode: python ; coding: utf-8 -*-


block_cipher = None


a = Analysis(
    ['melody_ear_trainer.py'],
    pathex=[],
    binaries=[],
    datas=[('./mapping/Mapping.txt', 'mapping'), ('./mapping/Scales.txt', 'mapping'), ('./mapping/Chords.txt', 'mapping'), ('./mapping/ChordSets.txt', 'mapping'), ('mp3', 'mp3'), ('piano_mp3', 'piano_mp3')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='melody_ear_trainer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
