#pragma once
// ===========================================================================
// Copyright 2018 Autodesk, Inc. All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
// ===========================================================================
//
// CLASS:    MPxDeformerNode
//
// ****************************************************************************

#include <maya/MStatus.h>
#include <maya/MTypes.h>
#include <maya/MObject.h>
#include <maya/MPxGeometryFilter.h>
#include <maya/MSelectionList.h>


// ****************************************************************************
// CLASS DECLARATION (MPxDeformerNode)

OPENMAYA_MAJOR_NAMESPACE_OPEN

//! \ingroup OpenMayaAnim MPx
//! \brief Base class for user defined deformers with per-vertex weights
/*!
 MPxDeformerNode builds on MPxGeometryFilter to allow the creation of deformers
 with per-vertex weights. Built-in Maya nodes which work in this way include
 the jiggle and cluster deformers.

 The weight values can be modified by the user using the set editing window or the percent command.
*/
class OPENMAYAANIM_EXPORT MPxDeformerNode : public MPxGeometryFilter
{
public:

	MPxDeformerNode();

	~MPxDeformerNode() override;

	MPxNode::Type type() const override;

	// return the weight value for the given index pair
	//
	float						weightValue( MDataBlock& mblock,
											 unsigned int multiIndex,
   										 unsigned int wtIndex);

	// Returns the weights per vertex (if any)
	OPENMAYA_AVAILABLE(2024)
	const float*			envelopeWeights( MDataBlock& mblock,
											 unsigned int multiIndex,
											 unsigned int* numWeights=nullptr);

	OPENMAYA_AVAILABLE(2019)
	void					setUseExistingConnectionWhenSetEditing(bool state);

	OPENMAYA_AVAILABLE(2019)
	MStatus					setDeformationDetails(unsigned int flags);
	OPENMAYA_AVAILABLE(2019)
	unsigned int			getDeformationDetails(MStatus * ReturnStatus = NULL);

	// Returns the indexMapper of the deformer for the specified multiIndex
 	OPENMAYA_AVAILABLE(2024)
 	const MIndexMapper& indexMapper(unsigned int multiIndex, MStatus * ReturnStatus = NULL) const override;

	// Inherited attributes
	//! weight list attribute, multi
	static MObject weightList;
	//! weight attribute, multi
	static MObject weights;

	static const char*	    className();

protected:
// No protected members

OPENMAYA_PRIVATE:
	static void				initialSetup();
};

OPENMAYA_NAMESPACE_CLOSE
