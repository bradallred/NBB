from distutils.core import setup
import py2app
setup(
    plugin = ['themes/nbb/nbb_theme.py'],
	data_files = ['themes/NBBTheme.py'],
	options=dict(py2app=dict(
							 extension='.nbbtheme',
							 semi_standalone = True,
							 plist=dict(
										NSPrincipalClass="NBBTheme",
										)
						   )
				 )
)
