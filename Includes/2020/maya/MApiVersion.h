#ifndef _MApiVersion
#define _MApiVersion
// ===========================================================================
// Copyright 2019 Autodesk, Inc. All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
// ===========================================================================

#ifndef MNoVersionString

// Create 2 cpp macros which will allow use to get the value of
// the #define MAYA_API_VERSION into a string and assigned to
// the global variable. (OpenMaya) (OpenMaya.py)

// This must be included on each plugin in only one compilation unit.
// Maya uses MApiVersion to know which devkit was used to build the plugin.
// As this must be an exported symbol, declaring it const and/or static breaks its visibility.

#define _versionString1( _version ) _versionString2(_version)
#define _versionString2( _version ) PLUGIN_EXPORT char MApiVersion[] =  #_version

#ifdef __cplusplus
extern "C" {
#endif

_versionString1(MAYA_API_VERSION);

#ifdef __cplusplus
}
#endif

// Delete the temporary macros
#undef _versionString1
#undef _versionString2

#endif // MNoVersionString

#endif /* _MApiVersion */
