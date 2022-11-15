# Satel Docker Build Push

This centralized GitHub action builds and pushes a docker image to registry 

## Usage 
```yml
name: "Deploy webapp"
on:
  pull_request:
    types:
      - opened
  push:
    tags:
      - "*"
    branches:
      - main  
    
    build-server:
    name: Build server
    needs: [generate-variables, build-client]
    runs-on: <host_name>
    # Map a step output to a job output, used in other jobs
    outputs:
      clean-branch-name: ${{ steps.registry-build-push.outputs.clean-branch-name }}
    steps:    
      - name: Build & Push server image to registry
        id: registry-build-push
        uses: SatelCreative/satel-docker-build-push@v1
        with:
          app-name: <app-name>
          satel-docker-user: ${{ secrets.SATEL_DOCKER_USER }}
          satel-docker-pass: ${{ secrets.SATEL_DOCKER_PASS }}
          client-docker-user: ${{ secrets.CLIENT_DOCKER_USER }}
          client-docker-pass: ${{ secrets.CLIENT_DOCKER_PASS }}
          satel-registry: docker.satel.ca
          client-registry: sb-docker.satel.ca
          dockerfile: <Dockerfile>
          current-branch-name: ${{needs.generate-variables.outputs.branch-name}}
          tag-name: ${{needs.generate-variables.outputs.tag-name}}  
```

 - `host_name` is `self-hosted` or the name of server where the action runner is hosted, `cosmicray` for example
 - `app-name` can be `st-pim` or `sb-pim` for example
 - `clean-branch-name` & `tag-name` parameters are set in a previous step  
 - `satel & client docker-user` & `satel & client docker-pass` are secrets added from the settings
 - `clean-branch-name` is an output generated using this action and needed for other steps/jobs
