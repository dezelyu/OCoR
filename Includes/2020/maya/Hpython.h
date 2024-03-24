#ifndef HPYTHON_H
#define HPYTHON_H

#include <Foundation/include/cxx17_enter_legacy_scope.hpp>

#include <Python/Python.h>
#include <Python/structmember.h>
#include <Python/compile.h>
#include <Python/eval.h>

#include <Foundation/include/cxx17_exit_legacy_scope.hpp>

#ifndef PyPUBLIC
	#ifdef _WIN32
		#define PyPUBLIC
	#else
		#define PyPUBLIC __attribute__ ((visibility ("default")))
	#endif
#endif

// With XCode, toupper is defined in /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/Python.framework/Headers/pyport.h:731:29: note: expanded from macro 'toupper'
// because of _PY_PORT_CTYPE_UTF8_ISSUE on __APPLE__ only
// Causing issue when including <iostream> after
#ifdef _PY_PORT_CTYPE_UTF8_ISSUE
    #undef isalnum
    #undef isalpha
    #undef islower
    #undef isspace
    #undef isupper
    #undef tolower
    #undef toupper
#endif

#endif
//-
// ==================================================================
// (C) Copyright 2006 by Autodesk, Inc. All Rights Reserved. By using
// this code,  you  are  agreeing  to the terms and conditions of the
// License  Agreement  included  in  the documentation for this code.
// AUTODESK  MAKES  NO  WARRANTIES,  EXPRESS  OR  IMPLIED,  AS TO THE
// CORRECTNESS OF THIS CODE OR ANY DERIVATIVE WORKS WHICH INCORPORATE
// IT.  AUTODESK PROVIDES THE CODE ON AN 'AS-IS' BASIS AND EXPLICITLY
// DISCLAIMS  ANY  LIABILITY,  INCLUDING CONSEQUENTIAL AND INCIDENTAL
// DAMAGES  FOR ERRORS, OMISSIONS, AND  OTHER  PROBLEMS IN THE  CODE.
//
// Use, duplication,  or disclosure by the U.S. Government is subject
// to  restrictions  set forth  in FAR 52.227-19 (Commercial Computer
// Software Restricted Rights) as well as DFAR 252.227-7013(c)(1)(ii)
// (Rights  in Technical Data and Computer Software),  as applicable.
// ==================================================================
//+
