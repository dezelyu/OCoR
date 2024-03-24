#pragma once
//-
// ===========================================================================
// Copyright 2021 Autodesk, Inc. All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
// ===========================================================================
//+

#include <maya/MColor.h>
#include <maya/MStatus.h>
#include <maya/MStringArray.h>

OPENMAYA_MAJOR_NAMESPACE_OPEN

// ****************************************************************************
// CLASS DECLARATION (MColorMixingSpaceHelper)
OPENMAYA_AVAILABLE(2023)
//! \ingroup OpenMayaRender
//! \brief Helper class for implementing correct color pickers that use widgets such as sliders and color wheels to mix colors
//!
//! Create an instance and set the mixing color space to transform a color or evaluate sliders.
//!\note All methods return the input color or the appropriate linear slider values when Maya color management is disabled.

class OPENMAYARENDER_EXPORT MColorMixingSpaceHelper
{
  public:
    MColorMixingSpaceHelper();
    ~MColorMixingSpaceHelper();

    //! Color transform direction
    enum Direction
    {
        kForward = 0, //!< apply the color transform
        kInverse      //!< invert the color transform
    };

    MStatus refresh();

    MStringArray getMixingSpaceNames(MStatus *returnedStatus = nullptr) const;
    MStatus setMixingSpace(const MString &name);
    MString mixingSpace() const;
    bool mixingSpaceHasViews() const;

    MStringArray getViewNames(MStatus *returnedStatus = nullptr) const;
    MStatus setView(const MString &name);
    MString view() const;

    MColor applyMixingTransform(const MColor &inputColor, Direction direction, MStatus *returnedStatus = nullptr) const;

    float mixingToSlider(float mixingPosition, float minPos, float maxPos) const;
    float sliderToMixing(float sliderPosition, float minPos, float maxPos) const;

  private:
    void *fImpl;

    MColorMixingSpaceHelper(const MColorMixingSpaceHelper &) = delete;
    MColorMixingSpaceHelper(MColorMixingSpaceHelper &&) = delete;
    MColorMixingSpaceHelper& operator = (const MColorMixingSpaceHelper &) = delete;
    MColorMixingSpaceHelper& operator = (MColorMixingSpaceHelper &&) = delete;
};

OPENMAYA_NAMESPACE_CLOSE
