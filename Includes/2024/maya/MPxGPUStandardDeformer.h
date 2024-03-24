#pragma once
// ===========================================================================
// Copyright 2021 Autodesk, Inc. All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
// ===========================================================================
//
// CLASS:    MPxGPUStandardDeformer
//
// ****************************************************************************
//
// CLASS DESCRIPTION (MPxGPUStandardDeformer)
//
//  MPxGPUStandardDeformer allows the user to extend the deformerEvaluator
//  plug-in to support additional nodes with GPU computation APIs
//  such as OpenCL.
//
// ****************************************************************************


#include <maya/MPxGPUDeformer.h>

OPENMAYA_MAJOR_NAMESPACE_OPEN

OPENMAYA_AVAILABLE(2023)

// ****************************************************************************
// CLASS DECLARATION (MPxGPUStandardDeformer)

//! \ingroup OpenMayaAnim MPx
//! \brief Base class for user defined GPU deformer override evaluators.
/*!
    MPxGPUStandardDeformer lets you create user-defined GPU deformer overrides
    in a way that simplifies working with weights and geometry subsets.

    It is important that the CPU node with which this GPU deformer is associated
    is derived from either MPxGeometryFilter or MPxDeformerNode. It will use the
    internal functionality of these node types to get the subset that is being
    deformed and the envelope weights to be used.
 */
class OPENMAYAANIM_EXPORT MPxGPUStandardDeformer : public MPxGPUDeformer
{
public:
    // Constructor
    MPxGPUStandardDeformer();
    // Destructor
    virtual ~MPxGPUStandardDeformer();

    // Called when the GPU deformer is being destroyed
    void terminate() override;

    // The deformer buffer holding the input positions
    const MGPUDeformerBuffer& inputPositions() const;
    // The deformer buffer holding the output positions
    MGPUDeformerBuffer& outputPositions();

    // Buffer with indices in subset
    MOpenCLBuffer& affectMapBuffer();
    // Buffer for weights in subset
    MOpenCLBuffer& weightsBuffer();

    // The number of points in a subset of the geometry
    unsigned int affectCount() const;
    // The total number of points of the geometry
    unsigned int fullCount() const;
    // Subset is the full geometry
    bool isIdentityMap() const;

    // Return the current envelope value
    float envelope() const;
    // Returns whether there are weights per vertex or not
    bool hasEnvelopeWeights() const;

    // Return the multiIndex
    OPENMAYA_AVAILABLE(2024)
    unsigned int multiIndex() const;
    OPENMAYA_AVAILABLE(2024)
    const MPlug& inputPlug() const;
    OPENMAYA_AVAILABLE(2024)
    const MIndexMapper& indexMapper() const;
    OPENMAYA_AVAILABLE(2024)
    virtual bool passThroughWithZeroEnvelope() const;

    // Prepares the evaluation of this deformer
    DeformerStatus prepareEvaluation(MDataBlock& block, const MEvaluationNode& evaluationNode, const MPlug& outputPlug, const MPlugArray& inputPlugs, const MGPUDeformerData& inputData, MGPUDeformerData& outputData, MAutoCLEvent& syncEvent);
    // Finish the evaluation of this deformer
    DeformerStatus finishEvaluation(MAutoCLEvent& syncEvent, MGPUDeformerData& outputData);

    // Initialize the output positions with the input positions
    cl_int initializeOutputPositions(MAutoCLEvent& syncEvent);

    // Uploads the affectMap to a GPU buffer if needed
    bool prepareAffectMapBuffer();
    // Uploads the weights to a GPU buffer if needed
    bool prepareWeightsBuffer(const MEvaluationNode& evaluationNode);

    // Return the name of the class
    static const char* className();

OPENMAYA_PRIVATE:
    class DataImpl;
    DataImpl *fDataImpl;
};

OPENMAYA_NAMESPACE_CLOSE
