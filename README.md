NBB - Neon Boom Box
===

# About

_Neon Boom Box_ is a themable and extensible front-end for in car entertainment. It utilizes _Objective-C_ for its core language and, although it uses Apples AppKit for its user interface, it provides subclasses and catagories extending AppKit control behavior.

# Theming

_NBB_ uses a powerful theming engine to customize the look and layout of the user interface to whatever you desire. _NBB_ themes use _Python_ scripting to create themes. Because we use _Python_ instead of "simpler" methods to define our theme you have unlimited options for what your theme can do. Through Python you will have access to the entire _Objective-C_ runtime including _NBBs_ core framework classes. Create your own control subclasses to define your own behavior or even create controls dynamically; in this way themes can function more like plugins!

Of course if you dont wish to create complex themes of your own, you can easily copy an _NBB_ theme and replace image and audio resources with your own (_NBB_ themes are Mac OS resource bundles) and/or edit a simple "plist" to customize an existing theme.

The dynamic theme engine can even be used to apply built-in "filters" at runtime (default filters and values are set in the themes plist). For example you can desaturate icons then apply a custom colorization without even having to open Photoshop!

Themes are not the only way to customize the _NBB_ interface. Buttons (and other controls implementing the appropriate protocol) can be re aranged at runtime. Push and hold the button to trigger iOS style icon "jiggling"; when in this state simply drag a button onto another "jiggling" icon to have them swap places.

# Modules

Modules are yet another way to customize _NBB_. _NBB_ comes with several modules of its own, but users can create their own using either _Objective-C_ or _Python_ using the _NBB_ Core Framework. Module interfaces should be created using Apple's Interface Builder. Use _NBB_ control classes instead of AppKit base classes; the theme engine will replace these with theme classes during interface loading. Be aware that a theme may adjust the size and position of elements (or other things) as they are loaded from the NIB.

_NBB_ will come with only a "Music" moduele and "Video" module at first, but more are planned, and hopefully many will be contributed by the comunity.
