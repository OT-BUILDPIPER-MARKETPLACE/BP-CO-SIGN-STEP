# BP-TRIVY-STEP
A BP step to orchestrate trivy execution

## Setup
* Clone the code available at [BP-TRIVY-STEP](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-TRIVY-STEP)
* Build the docker image
```
git submodule init
git submodule update
docker build -t ot/trivy:0.1 .
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

* Do local testing via image only

```
# Failed Scan
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src -e IMAGE_NAME="ot/trivy" -e IMAGE_TAG=0.1 ot/trivy:0.1
```

```
# Successful Scan
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src -e IMAGE_NAME="ot/trivy" -e IMAGE_TAG=0.1 -e SCAN_SEVERITY="CRITICAL" ot/trivy:0.1
```

### Filesystem Scan
Filesystem scan will scan a filesystem, this BP step can be used independently and with BuildPiper as well

```
# Successful Scan
docker run -it --rm -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src -e SCANNER=FILESYSTEM ot/trivy:0.1
```

* Debugging
```
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src -e COSIGN_PASSWORD="123" -e IMAGE_NAME="panuharshit/salary" -e IMAGE_SHA="sha256:d03a8c0d0283535de15393d6c334372f1e455f16f26d762c6effc02db4c320a7" -e COSIGN_KEY="LS0tLS1CRUdJTiBFTkNSWVBURUQgQ09TSUdOIFBSSVZBVEUgS0VZLS0tLS0KZXlKclpHWWlPbnNpYm1GdFpTSTZJbk5qY25sd2RDSXNJbkJoY21GdGN5STZleUpPSWpvMk5UVXpOaXdpY2lJNgpPQ3dpY0NJNk1YMHNJbk5oYkhRaU9pSlNaVmRTWmtWdlVHdGxhM1l6UW5sdmEwc3ZkRFF2Vm1Gd1NHSXJhbTVTClQwVmhiWEpITlVzeVZHaE5QU0o5TENKamFYQm9aWElpT25zaWJtRnRaU0k2SW01aFkyd3ZjMlZqY21WMFltOTQKSWl3aWJtOXVZMlVpT2lKTmFFMUxkbmg0ZFdzdlVWWkxhelprU21SRFNrMVZOa001YzFjNFNEZHhUQ0o5TENKagphWEJvWlhKMFpYaDBJam9pVEVzeWRWZG9RMm8zVlVKeFZsQm1LelozY3psblRVOVRka1U1U1hkWVpFUlZlazk0CmVGbzBjV3R1VGxGM1VrSkhOV0Z0U3poNWRVaE5MMmh5TnpoQlFYUnJTazlEVFRaRmFuQnBNR3RSVFdWa01rY3cKTVZGMmVXcDRaVXc0YldSMmJtRjRVU3RJVDJSVGJHVnNURzFJZVdWamRIZDZNVFEzWlRKR05FOWhXV0paVldOcwpWa1pIUVZkTmNtcFRiMFU0VGpGNldtaHBPR1JDTjFkaVp6QkljMmR4Um5WMmFUTXJOMk42UlRkT1R6Qm5UVEZNCk1VdENUMFZNUVRGbVRtbDFla2xIU1ZadVYzUkNjMGs1ZFVFOVBTSjkKLS0tLS1FTkQgRU5DUllQVEVEIENPU0lHTiBQUklWQVRFIEtFWS0tLS0tCg==" --entrypoint bash panuharshit/cosign-attach:1.4-test

docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:/src -e WORKSPACE=/ -e CODEBASE_DIR=src -e COSIGN_PASSWORD="123" -e IMAGE_NAME="panuharshit/salary" -e IMAGE_SHA="sha256:d03a8c0d0283535de15393d6c334372f1e455f16f26d762c6effc02db4c320a7" -e OUTPUT_ARG="sbom.cdx.intoto.jsonl" -e FORMAT_ARG="cyclonedx" -e COSIGN_PUB="LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFNmhHaEdRMmZhRnpQdnFSQ0FSL3lwd3llQ2wwagpjMDJmZVdTcXJFRkpadExKc3cwOERYQVk5ckJRbnN6am5scW13YkZEK2dKRUt0c3FVMnhNYnV1QzZBPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==" panuharshit/cosign-verify-attest:1.0-test
```
## Reference 
* [Docs](https://aquasecurity.github.io/trivy/v0.32/docs/)
* [Blog](https://www.prplbx.com/resources/blog/docker-part2/)
* [Image Scanning](https://aquasecurity.github.io/trivy/v0.32/docs/vulnerability/scanning/image/)
* [Filesystem Scanning](https://aquasecurity.github.io/trivy/v0.32/docs/vulnerability/scanning/filesystem/)
* [Format](https://aquasecurity.github.io/trivy/v0.27.1/docs/vulnerability/examples/report/)