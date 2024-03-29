# Copyright (C) 2008 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH:= $(call my-dir)

# libutils is a little unique: It's built twice, once for the host
# and once for the device.

commonSources:= \
	BasicHashtable.cpp \
	BlobCache.cpp \
	BufferedTextOutput.cpp \
	CallStack.cpp \
	Debug.cpp \
	FileMap.cpp \
	Flattenable.cpp \
	LinearTransform.cpp \
	Log.cpp \
	PropertyMap.cpp \
	RefBase.cpp \
	SharedBuffer.cpp \
	Static.cpp \
	StopWatch.cpp \
	String8.cpp \
	String16.cpp \
	StringArray.cpp \
	SystemClock.cpp \
	TextOutput.cpp \
	Threads.cpp \
	Timers.cpp \
	Tokenizer.cpp \
	Unicode.cpp \
	VectorImpl.cpp \
	WorkQueue.cpp \
	ZipFileCRO.cpp \
	ZipFileRO.cpp \
	ZipUtils.cpp \
	misc.cpp

host_commonCflags := -DLIBUTILS_NATIVE=1 $(TOOL_CFLAGS)

ifeq ($(HOST_OS),windows)
ifeq ($(strip $(USE_CYGWIN),),)
# Under MinGW, ctype.h doesn't need multi-byte support
host_commonCflags += -DMB_CUR_MAX=1
endif
endif

host_commonLdlibs :=

ifeq ($(TARGET_OS),linux)
host_commonLdlibs += -lrt -ldl
endif


# For the host
# =====================================================
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= $(commonSources)
ifeq ($(HOST_OS), linux)
LOCAL_SRC_FILES += Looper.cpp
endif
LOCAL_MODULE:= libutils
LOCAL_STATIC_LIBRARIES := libz
LOCAL_C_INCLUDES := \
	external/zlib
LOCAL_CFLAGS += $(host_commonCflags)
LOCAL_LDLIBS += $(host_commonLdlibs)
include $(BUILD_HOST_STATIC_LIBRARY)


# For the host, 64-bit
# =====================================================
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= $(commonSources)
ifeq ($(HOST_OS), linux)
LOCAL_SRC_FILES += Looper.cpp
endif
LOCAL_MODULE:= lib64utils
LOCAL_STATIC_LIBRARIES := libz
LOCAL_C_INCLUDES := \
	external/zlib
LOCAL_CFLAGS += $(host_commonCflags) -m64
LOCAL_LDLIBS += $(host_commonLdlibs)
include $(BUILD_HOST_STATIC_LIBRARY)


# For the device
# =====================================================
include $(CLEAR_VARS)


# we have the common sources, plus some device-specific stuff
LOCAL_SRC_FILES:= \
	$(commonSources) \
	Looper.cpp \
	Trace.cpp

ifeq ($(TARGET_OS),linux)
LOCAL_LDLIBS += -lrt -ldl
endif

LOCAL_C_INCLUDES += \
		bionic/libc/private \
		external/zlib

LOCAL_LDLIBS += -lpthread

LOCAL_SHARED_LIBRARIES := \
	liblog \
	libcutils \
	libdl \
	libcorkscrew \
	libz

ifeq ($(TARGET_BUILD_VARIANT),eng)
ifeq ($(filter banyan_addon banyan_addon_x86,$(TARGET_PRODUCT)),)
ifeq ($(MTK_INTERNAL),yes)
# mtk80143: enable FP and ARM build for debug15 memory debugging
LOCAL_CFLAGS += \
		-fno-omit-frame-pointer \
		-mapcs
LOCAL_ARM_MODE := arm
endif	
endif
endif


LOCAL_MODULE:= libutils
include $(BUILD_SHARED_LIBRARY)

# Include subdirectory makefiles
# ============================================================

# If we're building with ONE_SHOT_MAKEFILE (mm, mmm), then what the framework
# team really wants is to build the stuff defined by this makefile.
ifneq (true,$(BUILD_TINY_ANDROID))
ifeq (,$(ONE_SHOT_MAKEFILE))
include $(call first-makefiles-under,$(LOCAL_PATH))
endif
endif

