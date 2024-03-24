#include <maya/MFnPlugin.h>
#include <maya/MArgList.h>
#include <maya/MObject.h>
#include <maya/MGlobal.h>
#include <maya/MPxCommand.h>
class command final : public MPxCommand {
public:
	inline static void* creator() {
		return new command();
	}
	inline virtual MStatus doIt(const MArgList& arguments) {
		MString string {"confirmDialog -title \"Command\" -message \"I am a simple Maya command!!!\""};
		return MGlobal::executeCommand(string);
	}
};
MStatus initializePlugin(MObject object) {
	MFnPlugin plugin {object};
	return plugin.registerCommand("command", command::creator);
}
MStatus uninitializePlugin(MObject object) {
	MFnPlugin plugin {object};
	return plugin.deregisterCommand("command");
}
