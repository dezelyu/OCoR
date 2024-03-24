
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
//
// ****************************************************************************
//
// CLASS:    MTimeSliderCustomDrawManager
//
// *****


#include <maya/MStatus.h>
#include <maya/MTime.h>
#include <maya/MTypes.h>
#include <maya/MColor.h>
#include <maya/MString.h>
#include <maya/MTime.h>
#include <maya/MSharedPtr.h>


OPENMAYA_MAJOR_NAMESPACE_OPEN


OPENMAYA_AVAILABLE(2023)
class OPENMAYAUI_EXPORT MTimeSliderDrawPrimitive{
public:

	OPENMAYA_ENUM (MPrimitiveType,
		kFilledRect,			/*!< Draws a filled rectangle with no border. */
		kUpperOutline,			/*!< Draws an outline with no bottom side. */
		kFullOutline,			/*!< Draws an outline on all sides. */
		kVerticalLine,			/*!< Draws a vertical line at startTime. */
		kBracket				/*!< Draws a bracket from start to end time. */
    );
    OPENMAYA_ENUM (MEditPrimitiveType,
		kNone,					// default value
		kMovePrimitive,			// Move primitive start and end time together
		kMoveStartTime,			// Move only start time of primitive while start < end time
		kMoveEndTime			// Move only end time of primitive while end > start time
    );
    MTimeSliderDrawPrimitive(MPrimitiveType, MTime startTime, MTime endTime, MColor color, double bottom=0, double height= -1, unsigned int priority = 0);
    MTimeSliderDrawPrimitive(const MTimeSliderDrawPrimitive&);
    MTimeSliderDrawPrimitive& operator=(const MTimeSliderDrawPrimitive&);

    MTimeSliderDrawPrimitive& operator=(MTimeSliderDrawPrimitive&&)= delete;
    MTimeSliderDrawPrimitive() = delete;
    MTimeSliderDrawPrimitive(MTimeSliderDrawPrimitive&&) = delete;
    ~MTimeSliderDrawPrimitive();


	void 					setPriority		(unsigned int p);
	unsigned int 			priority		() const;
	// set/get methods
	void					setDrawType		(MPrimitiveType type);
	MPrimitiveType		    drawType		() const;

	void    				setStartTime	(const MTime& start);
	MTime	    			startTime		() const;

	void					setEndTime		(const MTime& end);
	MTime				    endTime			() const;

	void					setHeight		(double height);
	double					height			() const;

	void					setBottom		(double bottom);
	double					bottom			() const;

	void					setColor		(const MColor& color);
	MColor				    color			() const;

	void					setLabel		(const MString& label);
	MString					label			() const;

	//tool tip for this particular primitive overrides the DrawObject tooltip
	void					setTooltip		(const MString& tooltip);
	MString					tooltip			() const;



OPENMAYA_PRIVATE:
    struct Impl;
    MTimeSliderDrawPrimitive(Impl*);
    Impl* mImpl;
};

OPENMAYA_AVAILABLE(2023)
class OPENMAYAUI_EXPORT MTimeSliderDrawPrimitives{
public:
    MTimeSliderDrawPrimitives();
    MTimeSliderDrawPrimitives(const MTimeSliderDrawPrimitives& other) = delete;
    MTimeSliderDrawPrimitives(MTimeSliderDrawPrimitives&& other);

    MTimeSliderDrawPrimitives& operator=(const MTimeSliderDrawPrimitives&);
    MTimeSliderDrawPrimitives& operator=(MTimeSliderDrawPrimitives&&);

    ~MTimeSliderDrawPrimitives();

    void clear();
    bool empty() const;
    size_t length() const;

    void append	(const MTimeSliderDrawPrimitive& value);
    void append (const MTimeSliderDrawPrimitives& list);
    void setAt(size_t pos, const MTimeSliderDrawPrimitive& prim);

    MTimeSliderDrawPrimitive operator[](size_t pos) const;

OPENMAYA_PRIVATE:
    struct Impl;
    Impl* mImpl;
};

OPENMAYA_AVAILABLE(2023)
class OPENMAYAUI_EXPORT MStartPrimitiveEditingFct {
public:
    virtual ~MStartPrimitiveEditingFct();
    virtual void operator()(MTime time) = 0;
};

OPENMAYA_AVAILABLE(2023)
class OPENMAYAUI_EXPORT MEditPrimitiveFct {
public:
    virtual ~MEditPrimitiveFct();
    virtual void operator()(MTime offset, bool snap, double currentTime, 
        MTimeSliderDrawPrimitive::MEditPrimitiveType editType) = 0;
};

OPENMAYA_AVAILABLE(2023)
class OPENMAYAUI_EXPORT MStopPrimitiveEditingFct {
public:
    virtual ~MStopPrimitiveEditingFct();
    virtual void operator()() = 0;
};

OPENMAYA_AVAILABLE(2023)
class OPENMAYAUI_EXPORT MTimeSliderCustomDrawManager {
public:
    using MCustomDrawID = int;

    static constexpr int kUseDefaultHeight = -1;
    OPENMAYA_ENUM (MDrawLocation, kAbove, kBelow, kOn );
    MTimeSliderCustomDrawManager();
    ~MTimeSliderCustomDrawManager();

    static MTimeSliderCustomDrawManager& instance();

    MCustomDrawID		registerCustomDrawOn		(const MString& name, int drawLayer);
	MCustomDrawID		registerCustomDrawOutside	(MDrawLocation loc,
                                                     const MString& name,
                                                     const MString& tooltip,
                                                     int drawPriority, int height = kUseDefaultHeight);

    void		deregisterCustomDraw		(MCustomDrawID id);
    void		clearDrawPrimitives			(MCustomDrawID id);
    void		setDrawPrimitives			(MCustomDrawID id, const MTimeSliderDrawPrimitives& prims);
    void		setDrawPrimitives			(MCustomDrawID id, MTimeSliderDrawPrimitives&& prims);



	void		setDrawVisible				(MCustomDrawID id, bool vis);
	void		setDrawLayer				(MCustomDrawID id, int drawLayer);
	void		setDrawHeight				(MCustomDrawID id, int height);
	void		setDrawLocation				(MCustomDrawID id, MDrawLocation loc);
	void		setDrawPriority				(MCustomDrawID id, int drawPriority);
	void		setTooltip					(MCustomDrawID id, const MString& tooltip);
	void		setStartPrimitiveEditFunction	(MCustomDrawID id, MSharedPtr<MStartPrimitiveEditingFct> fct);
	void		setEditPrimitiveFunction		(MCustomDrawID id, MSharedPtr<MEditPrimitiveFct> fct);
	void		setStopPrimitiveEditFunction	(MCustomDrawID id, MSharedPtr<MStopPrimitiveEditingFct> fct);
    void 		setBackgroundColor			(MCustomDrawID id, MColor color);

    void		requestTimeSliderRedraw		() const;
    bool		empty	                    () const ;

private:
    //deleted function
    MTimeSliderCustomDrawManager(const MTimeSliderCustomDrawManager&)=delete;
    MTimeSliderCustomDrawManager(MTimeSliderCustomDrawManager&&)=delete;
    MTimeSliderCustomDrawManager& operator=(const MTimeSliderCustomDrawManager&) = delete;
    MTimeSliderCustomDrawManager& operator=(MTimeSliderCustomDrawManager&&) = delete;

    struct Impl;
    Impl* mImpl;
};

OPENMAYA_NAMESPACE_CLOSE