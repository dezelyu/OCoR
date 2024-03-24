#ifndef _MCacheSchema
#define _MCacheSchema
// ===========================================================================
// Copyright 2019 Autodesk, Inc. All rights reserved.
//
// Use of this software is subject to the terms of the Autodesk license
// agreement provided at the time of installation or download, or which
// otherwise accompanies this software in either electronic or hard copy form.
// ===========================================================================

#include <maya/MPlug.h>
#include <maya/MPlugArray.h>
#include <maya/MTypes.h>

#include <cstdint>
#include <iterator>

OPENMAYA_MAJOR_NAMESPACE_OPEN

class MCacheSchema;

//! \brief Empty shell sentinel denoting the end of the range
struct MCacheSchemaAttributesIteratorSentinel {};

//! \brief Iterator object of MCacheSchema
//!
//! Satisfy the concept of ForwardRange<const MPlug>
class OPENMAYA_EXPORT MCacheSchemaAttributesIterator {
public:
	// C++ iterator requirements
	using iterator_category = std::forward_iterator_tag;
	using value_type        = const MPlug;
	using reference         = value_type &;
	using pointer           = value_type *;
	using difference_type   = std::ptrdiff_t;

	// C++ 17 Sentential
	using Sentinel = MCacheSchemaAttributesIteratorSentinel;

	//! \brief Construct an attribute iterator at the begin of the schema
	explicit	MCacheSchemaAttributesIterator(const MCacheSchema*);
	//! \brief Construct an attribute iterator at the end of the schema
				MCacheSchemaAttributesIterator(const MCacheSchema*, Sentinel);
	~MCacheSchemaAttributesIterator() = default; // Iterator are trivial data

	//! \brief Get the current element this iterator points to
	//!
	//!  [[expect: !done()]]
	reference get() const;
	//! \brief Check if this iterator has reached the end of the range
	bool done() const;
	//! \brief Advance this iterator to the next element
	//!
	//!  [[expect: !done()]]
	void advance();

BEGIN_NO_SCRIPT_SUPPORT:

	MCacheSchemaAttributesIterator& operator++() { advance(); return *this; }

	reference operator*() const { return get(); }
	pointer operator->() const { return &get(); }

	bool operator==(Sentinel) const { return done(); }
	bool operator!=(Sentinel) const { return !done(); }

	bool operator==(const MCacheSchemaAttributesIterator& ) const;
	bool operator!=(const MCacheSchemaAttributesIterator& rhs) const { return !(*this == rhs); }

END_NO_SCRIPT_SUPPORT:

private:
	alignas(8) char _storage[48];
	alignas(8) mutable char _storage2[24];
};

//! \brief Range view of an MCacheSchema object
struct MCacheSchemaAttributesRange {
private:
	MCacheSchemaAttributesRange() = delete;
	~MCacheSchemaAttributesRange() = delete;
	MCacheSchemaAttributesRange(const MCacheSchemaAttributesRange&) = delete;
	MCacheSchemaAttributesRange& operator=(const MCacheSchemaAttributesRange&) = delete;
public:
	using iterator = MCacheSchemaAttributesIterator;
	MCacheSchemaAttributesIterator begin() const { return MCacheSchemaAttributesIterator(reinterpret_cast<const MCacheSchema*>(this)); }
	MCacheSchemaAttributesIterator end() const   { return MCacheSchemaAttributesIterator(reinterpret_cast<const MCacheSchema*>(this), MCacheSchemaAttributesIteratorSentinel{}); }
};

/*!
\brief		Defines a node's behavior when participant EM Cached Playback

			Can be used to query or modify the attributes being cached
			and request special support for the node.

\warning	Do not store pointers to this object
\warning	Users cannot construct or destroy this Maya object
*/
class OPENMAYA_EXPORT MCacheSchema {
private:
	MCacheSchema()  = delete;
	~MCacheSchema() = delete;

public:
	//! \brief	The attributes that planned to be cached
	//!
	//!			Removed attributes will not be included in this list.
	//!
	//! \warning This list may differ from what Maya get cached in the frame-evaluation-time.
	//!			 Attributes skipped at frame-pre-evaluation time with `MEvaluationNode::skipEvaluation` will not be cached anyway.
	const MCacheSchemaAttributesRange& attributes() const { return reinterpret_cast<const MCacheSchemaAttributesRange&>(*this); }

	void reset();

	MStatus add(const MObject&);
};

OPENMAYA_NAMESPACE_CLOSE
#endif // _MCacheSchema