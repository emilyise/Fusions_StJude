# set wd 
P_DIR="/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude"

# make easybuild directory in scratch
mkdir -p "${P_DIR}/easybuild"
cd "${P_DIR}/easybuild"

# pull easybuild files to vscratch
wget https://raw.githubusercontent.com/easybuilders/easybuild-easyconfigs/develop/easybuild/easyconfigs/n/Nextflow/Nextflow-26.04.6.eb

wget https://raw.githubusercontent.com/easybuilders/easybuild-easyconfigs/develop/easybuild/easyconfigs/j/Java/Java-25.36.eb

# load easybuild module 
module load easybuild

# export modulepath
export MODULEPATH=${P_DIR}/easybuild:$MODULEPATH

# build java
eb ${P_DIR}/easybuild/Java-25.36.eb \
    --installpath=${P_DIR}/easybuild

export JAVA_HOME=/projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/easybuild/software/Core/java/25.36
export PATH=$JAVA_HOME/bin:$PATH

# build nextflow
## change the Nextflow .eb file to Java 25.36 instead of 25 before running 
## dependencies = [('Java', '25.36')]
eb ${P_DIR}/easybuild/Nextflow-26.04.6.eb \
    --robot-paths=${P_DIR}/easybuild \
    --installpath=${P_DIR}/easybuild/software \
    --robot

# use nextflow 
module use /projects/rpci/joyceohm/Emily/2026_Fusions_St_Jude/easybuild/software/modules

# and load it to see if we've got it 
module load Core/nextflow/26.04.6
nextflow -version