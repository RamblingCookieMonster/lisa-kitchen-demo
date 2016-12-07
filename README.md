# LISA16 Test-Kitchen Demo

Demo pipeline for LISA16.  This evolved over time, so some ugliness and scraps of tape remain.

This is meant to demo test-kitchen, but could potentially solve two minor problems:

* You might be running tests on a system with artifacts and configurations in place that result in misleading test results
* You might be authoring code on a platform or version of PowerShell that isn't compatible with the tools in your build pipeline (hopefully this changes quickly)

So!  If you're not familiar with Ruby, how do you get started?

## Prerequisites

* Make sure you have Ruby, VirtualBox*, and Vagrant
* Make sure you have Bundler (`gem install bundler`)
* Browse to this repo, and `bundle install`.  This pulls down the dependencies listed in the Gemfile
* You're ready to go!

`*`: But I use Hyper-V!  No problem:

* Simple solution: [Boot without Hyper-V](http://www.hanselman.com/blog/SwitchEasilyBetweenVirtualBoxAndHyperVWithABCDEditBootEntryInWindows81.aspx).
* Hands-on option: Playe with the [Hyper-V driver](https://github.com/test-kitchen/kitchen-hyperv).  [Examples](https://gaelcolas.com/2016/07/11/introduction-to-kitchen-dsc/) abound.

## What's Actually Happening?

Stay tuned.  Will update this.  Basically:

* You run `Start-Build.ps1`
* `Start-Build` sees that you don't have the default Test-Kitchen working directory (`$ENV:\Kitchen`), runs `bundle exec kitchen test`
* `kitchen test` reads the .kitchen.yml file.
  * It pulls down a vagrant box if you don't have it
  * It uses the shell provisioner (vs. DSC, Puppet, Ansible, etc.), that copies in the whole repo, and runs `Start-Build` again!
  * This time, `Start-Build` sees the Kitchen folder, and defaults to bootstraping the system with `PSDepend`
  * `PSDepend` grabs a bunch of pre-requisites defined in `build\requirements.psd1`
  * Kitchen continues on, and runs the verifier stage.  Again, we're using the shell to kick off `Start-Build` with a `-Verify` switch (rather than the Pester verifier)
  * `Start-Build` kicks off `Invoke-Build` against `build\build.ps1`
  * `build.ps1` Defines variables, invokes Pester, deploys things in `build\my.deploy.ps1` with PSDeploy

Right.  Duct tape and bubble gum.  Maybe s/duct/masking.

## So... How do I use this?

This is more of a demo, but if it meets your needs, you can certainly use it.

* Toss a module, configuration, whatever you need in the repo
* Adjust `build\requirements.psd1` as needed
* Configure / bootstrap / provision as needed in the `Start-Build` provision section.  Ctrl+f `# Do some things!`
* Adjust `build\build.ps1` to run tests, deployments, and other tasks as needed
* Refer to files from the repo via `$ENV\Kitchen\Data`.  Note that hidden files (e.g. `.something`) won't be copied over.
* Play

You may find that typical tasks are better fit within the DSC or other configuration management provisioners, and Pester verifier.

## Further Reading

More to come, but the followin were quite handy:

* [Testing Ansible Roles Against Windows with Test-Kitchen](https://hodgkins.io/testing-ansible-roles-windows-test-kitchen)
* [Introduction to Kitchen-DSC](https://gaelcolas.com/2016/07/11/introduction-to-kitchen-dsc/)
* Various GitHub repos.  e.g. [1](https://github.com/smurawski/dsc-kitchen-project), [2](https://github.com/powershellorg/cwebadministration/tree/smurawski/adding_tests)
