# see NBBTheme.h and NBBThemeEngine.h
# include this module in your python code using "from NBBTheme import *"
# simply subclass NBBThemeBase and use the ThemeEngine instance to create your interface

from Foundation import *
from AppKit import *

NBBThemeBase = lookUpClass('NBBTheme')
NBBThemeEngine = lookupClass('NBBThemeEngine')

# TODO: add our custom control subclasses

ThemeEngine = NBBThemeEngine.sharedThemeEngine()
