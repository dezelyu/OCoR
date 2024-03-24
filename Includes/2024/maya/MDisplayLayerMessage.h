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
// CLASS:    MDisplayLayerMessage
//
// ****************************************************************************

#include <maya/MMessage.h>
#include <maya/MDeprecate.h>

OPENMAYA_MAJOR_NAMESPACE_OPEN

// ****************************************************************************
// CLASS DECLARATION (MDisplayLayerMessage)

//! \ingroup OpenMaya
//! \brief Dependency node messages. 
/*!
	This class is used to register callbacks for display layer membership
    changes.

	Each method returns an id which is used to remove the callback.

    To remove a callback use MMessage::removeCallback.
	All callbacks that are registered by a plug-in must be removed by that
	plug-in when it is unloaded. Failure to do so will result in a fatal error.
*/
class OPENMAYA_EXPORT MDisplayLayerMessage : public MMessage
{
public:
	//! \brief Pointer to a DisplayLayerMemberChanged callback
	/*!
	\param[in] clientData Pointer to user-defined data supplied when the callback was registered.
	\param[in] memberPath Ufe path to the member that was added or removed from the display list.	
	*/
	typedef void (*MDisplayLayerMemberChangedFunction)(void* clientData, const MString& memberPath);

	static MCallbackId	addDisplayLayerMemberChangedCallback(
								MDisplayLayerMemberChangedFunction func,
								void * clientData = NULL,
								MStatus * ReturnStatus = NULL );

	static const char* className();
};

OPENMAYA_NAMESPACE_CLOSE
