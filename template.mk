#Target = x x.so x.a test
#Source	=
#Test =
#Lib =
#LibPath =
#Include =
#Define =
#CFLAGS	=
#CXXFLAGS =
#LDFLAGS =
#Rpath =

#CC = cc
#CXX = c++

include $(CMK_CONFIG)

UnixName ?= $(shell uname)
OutputPath ?= .
TargetType = $(suffix $(Target))
ifeq ($(MAKECMDGOALS),test)
	TargetType =
	Source = $(Test)
endif

# TargetPath & TargetFile
ifeq ($(TargetType),)
	TargetPath = $(OutputPath)/bin
	TargetFile = $(TargetPath)/$(Target)
	
	ifeq ($(Rpath),)
		Rpath = ../lib
	endif
endif
ifeq ($(TargetType),.a)
	TargetPath = $(OutputPath)/lib
	TargetFile = $(TargetPath)/$(Target)
	CFLAGS += -fPIC
endif
ifeq ($(TargetType),.so)
	TargetPath = $(OutputPath)/lib
	TargetFile = $(TargetPath)/$(Target)
	CFLAGS += -fPIC
endif

# Include & Define
Include += $(OutputPath)/include
ifneq ($(VendorPath),)
	Include += $(Import:%=$(VendorPath)/%/include)
else ifneq ($(CWORK_PATH),)
	Include += $(Import:%=$(CWORK_PATH)/%/include)
endif

CFLAGS += $(Include:%=-I%) $(Define:%=-D%) -m64

# LibPath
LibPath += $(OutputPath)/lib
ifneq ($(VendorPath),)
	LibPath += $(Import:%=$(VendorPath)/%/lib)
else ifneq ($(CWORK_PATH),)
	LibPath += $(Import:%=$(CWORK_PATH)/%/lib)
endif

LDFLAGS += $(LibPath:%=-L%) $(Lib:%=-l%)

ifeq ($(MAKECMDGOALS),test)
	TargetBase = $(basename $(Target))
	TargetLib = $(TargetBase:lib%=%)
	LDFLAGS += -l$(TargetLib)

	TestTarget = $(basename $(Source))
	TestTargetFile = $(TestTarget:test/%=$(TargetPath)/%)
endif

# ObjectPath
ObjectPath = $(OutputPath)/obj

ifeq ($(UnixName),Linux)
	LDFLAGS += -rdynamic
endif

# Link
ifeq ($(TargetType),)
	Link = g++ -Wl,-rpath,$(Rpath) -o $@ $^ $(LDFLAGS)
endif

ifeq ($(TargetType),.a)
	CFLAGS += -fPIC
	Link = ar cr $@ $^
endif

ifeq ($(TargetType),.so)
	Shared = -shared
	ifeq ($(UnixName),Darwin)
		Shared = -dynamiclib -install_name @rpath/$(Target)
	endif
	CFLAGS += -fPIC
	Link = g++ $(Shared) $(LDFLAGS) -o $@ $^
endif

CXXFLAGS += $(CFLAGS)

Obj = $(addsuffix .o,$(basename $(Source)))
Dep = $(addsuffix .d,$(basename $(Source)))

SourcePath = $(dir $(Source))
$(shell mkdir -p $(TargetPath) $(SourcePath:%=$(ObjectPath)/%))

define info
	@echo ">>>> $(UnixName) cmk:" $(Target) $(MAKECMDGOALS)
	@echo CC = $(CC) $(CFLAGS)
	@echo CXX = $(CXX) $(CXXFLAGS)
	@echo Link = $(Link)
	@echo "<<<<"
endef

.PHONY: all test info clean
all: info $(TargetFile)

test: info $(TestTargetFile)

clean:
	rm -rf obj lib bin

info:
	$(info)

$(OutputPath)/bin/$(Target): $(Obj:%=$(ObjectPath)/%)
	@echo Link $@ ...
	@$(Link)

$(OutputPath)/lib/$(Target): $(Obj:%=$(ObjectPath)/%)
	@echo Link $@ ...
	@$(Link)

$(OutputPath)/bin/%: $(ObjectPath)/test/%.o
	@echo Link $@ ...
	@$(Link)

-include $(Dep:%=$(ObjectPath)/%)

$(ObjectPath)/%.o: %.c
	@echo CC $< ...
	@$(CC) $(CFLAGS) -o $@ -c $<

$(ObjectPath)/%.o: %.cpp
	@echo CXX $< ...
	@$(CXX) $(CXXFLAGS) -o $@ -c $<

$(ObjectPath)/%.d: %.c
	@$(CC) -MM $(CFLAGS) $< -MT $(@:%.d=%.o) -MT $@ > $@

$(ObjectPath)/%.d: %.cpp
	@$(CXX) -MM $(CXXFLAGS) $< -MT $(@:%.d=%.o) -MT $@ > $@
