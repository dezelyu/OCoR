#pragma once
//-
// ===========================================================================
// Copyright 2022 Autodesk, Inc. All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
// ===========================================================================
//+
//
// CLASS:    MFnDisplayLayer
//
// ****************************************************************************
//
// CLASS DESCRIPTION (MFnDisplayLayer)
//
// ****************************************************************************

#include <maya/MFnDependencyNode.h>
#include <maya/MString.h>

// ****************************************************************************
// DECLARATIONS

class TsetCmd;
class Tstring;

OPENMAYA_MAJOR_NAMESPACE_OPEN

// ****************************************************************************
// CLASS DECLARATION (MFnDisplayLayer)

//! \ingroup OpenMaya MFn
//! \brief Function Set for display layers. 
/*!
  MFnDisplayLayer is the function set that is used for querying the contents
  of a display layer.
*/
class OPENMAYA_EXPORT MFnDisplayLayer : public MFnDependencyNode
{
    declareMFn(MFnDisplayLayer, MFnDependencyNode);

public:
    MStatus getMembers( MSelectionList &members) const;
    MStatus add( const MString &pathString );
    MStatus add( const MDagPath &dagPath );
    MStatus remove( const MString &pathString );
    MStatus remove( const MDagPath &dagPath );
    bool    contains( const MString &pathString, MStatus* status=nullptr ) const;
    bool    contains( const MDagPath &dagPath ) const;
    bool    containsAncestorInclusive( const MString &pathString, MStatus* status=nullptr ) const;
    bool    containsAncestorInclusive( const MDagPath &dagPath ) const;

BEGIN_NO_SCRIPT_SUPPORT:

    declareMFnConstConstructor( MFnDisplayLayer, MFnDependencyNode );

END_NO_SCRIPT_SUPPORT:

};

OPENMAYA_NAMESPACE_CLOSE
