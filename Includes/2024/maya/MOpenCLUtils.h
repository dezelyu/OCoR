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
// CLASS:    MOpenCLUtils
//
// ****************************************************************************

#include <maya/MStatus.h>
#include <maya/MString.h>
#include <maya/MTypes.h>
#include <maya/MOpenCLBuffer.h>
#include <maya/MOpenCLInfo.h>

OPENMAYA_MAJOR_NAMESPACE_OPEN

OPENMAYA_AVAILABLE(2023)

// ****************************************************************************
// CLASS DECLARATION (MOpenCLUtils)

//! \ingroup OpenMaya
//! \brief OpenCL functionality.
/*!

 General utilities for OpenCL, containing functions for uploading buffers
 and managing kernels.
*/
class OPENMAYA_EXPORT MOpenCLUtils
{
public:

    //! Upload mode.
    OPENMAYA_ENUM(UploadMode,
        kNonBlocking, // Indicates the write operation is nonblocking.
        kBlocking     // Indicates the write operation is blocking.
    );

    // Upload data to the GPU
    static cl_int uploadToGPU(size_t size, void* host_ptr, MOpenCLBuffer& buffer, UploadMode uploadMode);

    /*!
        \brief Uploads array data to a GPU Buffer.

        \param[in] array the CPU array to be uploaded
        \param[in] buffer the GPU buffer to which the data should be uploaded
        \param[in] uploadMode the uploadMode specifies whether the upload should happen in blocking or non-blocking mode

        \return
        \li <b>CL_SUCCESS</b> if the upload was succesfull
    */
    template <typename MArrayType, typename ElementType = decltype(MArrayType{}[0]), typename _req=decltype(MArrayType{}.length())>
    static cl_int uploadToGPU(const MArrayType& array, MOpenCLBuffer& buffer, UploadMode uploadMode=kBlocking)
    {
        MArrayType& nonConstArray = const_cast<MArrayType&>(array);
        return uploadToGPU(array.length()*sizeof(ElementType), array.length() > 0 ? (void*)&nonConstArray[0] : nullptr, buffer, uploadMode);
    }

    /*!
        \brief Uploads array data to a GPU Buffer.

        \param[in] array the std array to be uploaded
        \param[in] buffer the GPU buffer to which the data should be uploaded
        \param[in] uploadMode the uploadMode specifies whether the upload should happen in blocking or non-blocking mode

        \return
        \li <b>CL_SUCCESS</b> if the upload was succesfull
    */
    template <typename StdArrayType, typename _req=typename StdArrayType::value_type>
    static cl_int uploadToGPU(const StdArrayType& array, MOpenCLBuffer& buffer, UploadMode uploadMode)
    {
        constexpr auto element_size = sizeof(*array.data());
        return MOpenCLUtils::uploadToGPU(array.size() * element_size, array.empty() ? nullptr : (void*)array.data(), buffer, uploadMode);
    }

    // Upload matrix array data to the GPU
    static cl_int uploadToGPU(const MMatrixArray& array, MOpenCLBuffer& buffer, UploadMode uploadMode=kBlocking);
    // Upload generic array data to the GPU
    static cl_int uploadToGPU(const MObject& object, MOpenCLBuffer& buffer, UploadMode uploadMode, unsigned int* arrayLength=nullptr);
    // Upload (unsigned) integer array data to the GPU as unsigned char array
    static cl_int uploadToGPUAsUnsignedChar(const MObject& object, MOpenCLBuffer& buffer, unsigned int* arrayLength=nullptr);

    // Set the buffer as an argument of a kernel
    static cl_int setKernelArgBuffer(cl_kernel kernel, cl_uint argIndex, const MAutoCLMem& buffer, cl_int& errorCode, bool useBuffer=true);
    // Set the buffer as an argument of a kernel
    static cl_int setKernelArgBuffer(cl_kernel kernel, cl_uint argIndex, const MOpenCLBuffer& buffer, cl_int& errorCode, bool useBuffer=true);

    // Set the value as an argument of a kernel
    static cl_int setKernelArg(cl_kernel kernel, cl_uint argIndex, size_t argSize, const void* argValue, cl_int& errorCode);
    /*!
        \brief Used to set the argument value for a specific argument of a kernel.

        If the specified errorCode is not CL_SUCCES this function will do nothing. It will simply return the error code.
        Otherwise it will set the argument on the kernel and return the new errorCode.

        \param[in] kernel A valid kernel object.
        \param[in] argIndex The argument index. Arguments to the kernel are referred by indices that go from 0 for the leftmost argument to n - 1, where n is the total number of arguments declared by a kernel.
        \param[in] value The data that should be used as the argument value for the argument specified by argIndex
        \param[in,out] errorCode the previous error code which will be set to the new result if the previous code was CL_SUCCES

        \return
        \li <b>CL_SUCCESS</b> returns CL_SUCCESS if the function is executed successfully. Otherwise, it returns an OpenCL error code.
    */
    template<typename T>
    static cl_int setKernelArg(cl_kernel kernel, cl_uint argIndex, T value, cl_int& errorCode)
    {
        return setKernelArg(kernel, argIndex, sizeof(T), (const void*)&value, errorCode);
    }

    // Return the name of the class
    static const char* 	className();

protected:
    // No protected members

};

OPENMAYA_AVAILABLE(2023)

// ****************************************************************************
// CLASS DECLARATION (MOpenCLKernelInfo)

//! \ingroup OpenMaya
//! \brief OpenCL functionality.
/*!

 Wrapper for a MAutoCLKernel that will keep track of the work size and the
 element count. It also contains utility functions to more easily manage the
 loading, updating and argument setting of the kernel.
*/

class OPENMAYA_EXPORT MOpenCLKernelInfo
{
public:
    // Create an MOpenCLKernelInfo
    MOpenCLKernelInfo();
    virtual ~MOpenCLKernelInfo();

    // Release the kernel
    void reset();

    // Returns the array that describes the number of work-items
    const size_t* localWorkSize() const;
    // Returns the array that describes the number of global work-items
    const size_t* globalWorkSize() const;
    // Return the elementCount to be used by the kernel
    size_t elementCount() const;

    // Returns the kernel.
    MAutoCLKernel& kernel();
    // Returns the raw cl_kernel.
    cl_kernel get() const;
    // Returns whether this manages a object manages a non-null cl_kernel object.
    bool isNull() const;

    //  Load or updates the OpenCL kernel.
    OPENMAYA_MODIFIED(2024, "includePaths parameter added")
    bool loadOrUpdate(const MString& fileName, const MString& kernelName, int elementCount = 0, const MStringArray* includePaths = 0);
    //  Initializes the OpenCL kernel.
    OPENMAYA_MODIFIED(2024, "includePaths parameter added")
    bool loadKernel(const MString& fileName, const MString& kernelName, int elementCount = 0, const MStringArray* includePaths = 0);
    // Update the work size of the OpenCL kernel.
    bool updateWorkSize(int elementCount);
    // Invalidate the work size
    void invalidateWorkSize();

    // Set the buffer as an argument of this kernel
    cl_int setKernelArgBuffer(cl_uint argIndex, const MAutoCLMem& buffer, cl_int& errorCode, bool useBuffer=true);
    // Set the buffer as an argument of this kernel
    cl_int setKernelArgBuffer(cl_uint argIndex, const MOpenCLBuffer& buffer, cl_int& errorCode, bool useBuffer=true);

    /*!
        \brief Used to set the argument value for a specific argument of this kernel.

        If the specified errorCode is not CL_SUCCES this function will do nothing. It will simply return the error code.
        Otherwise it will set the argument on the kernel and return the new errorCode.

        \param[in] argIndex The argument index. Arguments to the kernel are referred by indices that go from 0 for the leftmost argument to n - 1, where n is the total number of arguments declared by a kernel.
        \param[in] value The data that should be used as the argument value for the argument specified by argIndex
        \param[in,out] errorCode the previous error code which will be set to the new result if the previous code was CL_SUCCES

        \return
        \li <b>CL_SUCCESS</b> returns CL_SUCCESS if the function is executed successfully. Otherwise, it returns an OpenCL error code.
    */
    template<typename T>
    cl_int setKernelArg(cl_uint argIndex, T value, cl_int& errorCode)
    {
        return MOpenCLUtils::setKernelArg(kernel().get(), argIndex, value, errorCode);
    }

    // Enqueue the execution of the kernel
    cl_int enqueueKernel(MAutoCLEventList& eventWaitList, MAutoCLEvent& event);

    // Return the name of the class
    static const char* 	className();

OPENMAYA_PRIVATE:
    struct KernelInfoImpl;
    KernelInfoImpl *fImpl;
};

OPENMAYA_NAMESPACE_CLOSE
