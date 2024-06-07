# BP-COSIGN-VERIFY-ATTESTATION
A BP step to orchestrate trivy execution

## Setup
* Clone the code available at [COSIGN-VERIFY-ATTESTATION](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-TRIVY-STEP)
* Build the docker image
```
git submodule init
git submodule update

docker build --no-cache -f cosign-verify-attest/Dockerfile -t registry.buildpiper.in/cosign-verify-attestation .
```
## Testing
This section will give you a walkthrough of how you can use this image to do various types of testing
Some of the global environment variables that control the behaviour of scanning
* SCAN_SEVERITY | Default - HIGH,CRITICAL | For possible values check documentation
* FORMAT_ARG | Default - html | For possible values check documentation
* OUTPUT_ARG | Default - trivy-report.html | Give any path as per your preference


### Docker Image Scan

Docker image scan will scan a docker image, this BP step can be used independently and with BuildPiper as well
If you want to use it independently you have to take care of below things
    * You have to set IMAGE_NAME env variable
    * You have to set IMAGE_TAG env variable
    * You have to mount /var/run/docker.sock
    * You have to set WORKSPACE env variable
    * You have to set CODEBASE_DIR env variable

* Do local testing via image 

* Debugging
```
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src -e COSIGN_PASSWORD="123" -e IMAGE_NAME="panuharshit/salary" -e IMAGE_SHA="sha256:d03a8c0d0283535de15393d6c334372f1e455f16f26d762c6effc02db4c320a7" -e SBOM_FORMAT_TYPE="cyclonedx" -e COSIGN_PUB="LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFNmhHaEdRMmZhRnpQdnFSQ0FSL3lwd3llQ2wwagpjMDJmZVdTcXJFRkpadExKc3cwOERYQVk5ckJRbnN6am5scW13YkZEK2dKRUt0c3FVMnhNYnV1QzZBPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==" registry.buildpiper.in/cosign-verify-attestation:1.0 
```
## Reference 
* [Docs](https://aquasecurity.github.io/trivy/v0.32/docs/)
* [Blog](https://www.prplbx.com/resources/blog/docker-part2/)
* [Image Scanning](https://aquasecurity.github.io/trivy/v0.32/docs/vulnerability/scanning/image/)
* [Filesystem Scanning](https://aquasecurity.github.io/trivy/v0.32/docs/vulnerability/scanning/filesystem/)
* [Format](https://aquasecurity.github.io/trivy/v0.27.1/docs/vulnerability/examples/report/)