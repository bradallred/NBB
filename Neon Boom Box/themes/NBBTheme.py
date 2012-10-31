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


# see NBBTheme.h and NBBThemeEngine.h
# include this module in your python code using "from NBBTheme import *"
# simply subclass NBBThemeBase and use the ThemeEngine instance to create your interface

from Foundation import *
from AppKit import *
from objc import lookUpClass

NBBThemeBase = lookUpClass('NBBTheme')
NBBThemeEngine = lookUpClass('NBBThemeEngine')

# TODO: add our custom control subclasses

ThemeEngine = NBBThemeEngine.sharedThemeEngine()
