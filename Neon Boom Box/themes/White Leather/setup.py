# Neon Boom Box - In-car entertainment front-end
# Copyright (C) 2012 Brad Allred
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

from distutils.core import setup
import py2app

setup(
	  plugin = ['themes/White Leather/White Leather.py'],
	  data_files = ['themes/NBBTheme.py'],
	  options = dict(py2app = dict(
								   semi_standalone = True,
								   plist = 'themes/White Leather/White Leather-Info.plist',
								   )
					 )
	  )
