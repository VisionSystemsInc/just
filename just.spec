# -*- mode: python -*-

import platform
import os

block_cipher = None

added_files=[('./vsi_common/linux', 'linux'),
             ('./vsi_common/env.bsh', '.')]

# Add for recipes
added_files.append(('./vsi_common/docker', 'docker'))

# Add tests to test just executable
added_files.append(('./vsi_common/tests', 'tests'))

if platform.system()=='Windows':
  console=False
  # console=True
else:
  console=True

if os.environ.get('VSI_MUSL', None)=='1':
  name='juste-'+platform.system()+'-musl-x86_64'
else:
  name='juste-'+platform.system()+'-x86_64'

a = Analysis(['just.py'],
             pathex=['.'],
             binaries=[],
             datas=added_files,
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
          cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name=name,
          debug=False,
          strip=False,
          upx=True,
          runtime_tmpdir=None,
          console=console )

