import os
import shutil
from optparse import OptionParser,OptionError

def main():
    usage = "Usage: %prog [options]"
    parser = OptionParser(usage)
    parser.add_option("-i","--inputFile",dest="inputFile",
            help="solution file")
    try:
        (options,args) = parser.parse_args()
    except OptionError,e:
        logger.error("Unable to parse command line options: %s" % e.msg)
        sys.exit(1)

	#map project paths to GUIDs
    f = open(options.inputFile, 'rU')
    ii = 1
    projects = dict()
    for line in f:
        line = line.strip()
        if line.startswith("Project("):
			projectDefinition = line.split("=")
			projectComponents = projectDefinition[1].split(",")
			projectPath = projectComponents[1]
			projectPath = projectPath.strip()
			projectGuid = projectComponents[2]
			projectGuid = projectGuid.strip()
			projectPath = projectPath.replace("\"", "")
			projectGuid = projectGuid.replace("\"", "")
			projects[projectGuid] = projectPath
    #for key in projects.iterkeys():
    #    print key, projects[key]			

    cwd = os.getcwd() + "\\"
	
	#make a second pass looking for references
    f = open(options.inputFile, 'rU')
    ii = 1
    referencingProjectName = ""
    referencedProjects = list()
    state = 0 #0 means simply looping, 1 means collecting references, 2 means writing out references
    for line in f:
        line = line.strip()
        if line.startswith("Project("):
			projectDefinition = line.split("=")
			projectComponents = projectDefinition[1].split(",")
			referencingProjectName = projectComponents[2]
			referencingProjectName = referencingProjectName.strip()
			referencingProjectName = referencingProjectName.replace("\"", "")
        elif line.startswith("ProjectSection(ProjectDependencies)"):
            state = 1
        elif line.startswith("EndProjectSection"):
		    state = 2
        elif 1 == state:
            projectDefinition = line.split("=")
            projectDefinition = projectDefinition[0].strip()
            referencedProjects.append(projectDefinition)
        elif 2 == state:
            output = "\t<ItemGroup>\n"
            projectFileName = projects[referencingProjectName]
            projectFileNameFullPath = cwd + projectFileName
            #print "Full path " + projectFileNameFullPath
            for project in referencedProjects:
                output += "\t\t<ProjectReference Include=\""
                referencedProjectFullPath = cwd + projects[project]
                relProjectFolder = os.path.dirname(projectFileNameFullPath)
                referencedProjectRelPath = os.path.relpath(referencedProjectFullPath, relProjectFolder)
            	output += referencedProjectRelPath
            	output += "\">\n"
            	output += "\t\t\t<Project>" + project + "</Project>\n"
            	output += "\t\t</ProjectReference>\n"
            output += "\t</ItemGroup>\n"
            #print output
            #reset state
            referencedProjects = list()
            state = 0
            #write output to project file
            f2 = open(projectFileName, 'rU')
            f3 = open(projectFileName + ".tmp", 'w')
            lastLine = ""
            firstPass = True
            for line in f2:
                if firstPass:
            	    lastLine = line
                    firstPass = False
                else:
            	    f3.write(lastLine)
                    lastLine = line
            f3.write(output)
            f3.write(lastLine)
            f2.close()
            f3.close()
            shutil.copyfile(projectFileName, projectFileName + ".orig")
            shutil.copyfile(projectFileName + ".tmp", projectFileName)
            print "Updating " + projectFileName
			
if __name__ == "__main__":
    main()