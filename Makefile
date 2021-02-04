#
# Copyright 2021, Seqera Labs, S.L. All Rights Reserved.
#

## DNAnexus quickstart
clean:
	rm -rf build
	
dx-pack:
	mkdir -p build/nf-dxapp/resources/usr/bin
	mkdir -p build/nf-dxapp/resources/opt/nextflow
	NXF_VER=21.02.0-edge NXF_HOME=build/nf-dxapp/resources/opt/nextflow bash -c 'curl get.nextflow.io | bash'
	mv nextflow build/nf-dxapp/resources/usr/bin/nextflow
	rm -rf build/nf-dxapp/resources/opt/nextflow/tmp

dx-build:
    # copy dnanexus template
	cp app/dxapp.* build/nf-dxapp/
	dx build build/nf-dxapp -f
	# info
	echo "Run with: dx run nf-dxapp --watch -y"

dx-run: 
	dx run nf-dxapp --watch -y
