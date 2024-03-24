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
// CLASS:    MFnDisplayLayerManager
//
// ****************************************************************************
//
// CLASS DESCRIPTION (MFnDisplayLayerManager)
//
// ****************************************************************************

#include <maya/MFnDependencyNode.h>
#include <maya/MString.h>
#include <maya/MObject.h>

// ****************************************************************************
// DECLARATIONS

class TsetCmd;
class Tstring;

OPENMAYA_MAJOR_NAMESPACE_OPEN

// ****************************************************************************
// CLASS DECLARATION (MFnDisplayLayerManager)

//! \ingroup OpenMaya MFn
//! \brief Function Set for display layer manager. 
/*!
  MFnDisplayLayerManager is the function set that is used for querying which
  display layer a Ufe item is a member of.
*/
class OPENMAYA_EXPORT MFnDisplayLayerManager : public MFnDependencyNode
{
	declareMFn(MFnDisplayLayerManager, MFnDependencyNode);

public:
    static MObject currentDisplayLayerManager();
    MObject getLayer( const MString &pathString, MStatus *status=nullptr ) const;
    MObject getLayer( const MDagPath &dagPath, MStatus *status=nullptr ) const;
    MObjectArray getAncestorLayersInclusive( const MString &pathString, MStatus *status=nullptr ) const;
    MObjectArray getAncestorLayersInclusive( const MDagPath &dagPath, MStatus *status=nullptr ) const;
    MObjectArray getAllDisplayLayers() const;

BEGIN_NO_SCRIPT_SUPPORT:

 	declareMFnConstConstructor( MFnDisplayLayerManager, MFnDependencyNode );

END_NO_SCRIPT_SUPPORT:

};

OPENMAYA_NAMESPACE_CLOSE
