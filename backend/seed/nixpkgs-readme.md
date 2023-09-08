<p align="center">
  <a href="https://nixos.org#gh-light-mode-only" rel="nofollow">
    <img src="https://raw.githubusercontent.com/NixOS/nixos-homepage/master/logo/nixos-hires.png" width="500px" alt="NixOS logo" style="max-width: 100%;">
  </a>
  <a href="https://nixos.org#gh-dark-mode-only" rel="nofollow">
    <img src="https://raw.githubusercontent.com/NixOS/nixos-artwork/master/logo/nixos-white.png" width="500px" alt="NixOS logo" style="max-width: 100%;">
  </a>
</p>
<p align="center">
  <a href="https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md"><img src="https://camo.githubusercontent.com/c9b1cef79411874371c6c98842d88aa45e2fd371b4c56bb7df275a12abdf789c/68747470733a2f2f696d672e736869656c64732e696f2f6769746875622f636f6e7472696275746f72732d616e6f6e2f4e69784f532f6e6978706b6773" alt="Contributors badge" data-canonical-src="https://img.shields.io/github/contributors-anon/NixOS/nixpkgs" style="max-width: 100%;"></a>
  <a href="https://opencollective.com/nixos" rel="nofollow"><img src="https://camo.githubusercontent.com/bfaf25aded7fd76089c9d1eb46fcd83063855dc43a1ff3a4746458f803365d43/68747470733a2f2f6f70656e636f6c6c6563746976652e636f6d2f6e69786f732f74696572732f737570706f727465722f62616467652e7376673f6c6162656c3d737570706f727465727326636f6c6f723d627269676874677265656e" alt="Open Collective supporters" data-canonical-src="https://opencollective.com/nixos/tiers/supporter/badge.svg?label=supporters&amp;color=brightgreen" style="max-width: 100%;"></a>
</p>
<p><a href="https://github.com/nixos/nixpkgs">Nixpkgs</a> is a collection of over
80,000 software packages that can be installed with the
<a href="https://nixos.org/nix/" rel="nofollow">Nix</a> package manager. It also implements
<a href="https://nixos.org/nixos/" rel="nofollow">NixOS</a>, a purely-functional Linux distribution.</p>
<h1><a id="user-content-manuals" class="anchor" aria-hidden="true" tabindex="-1" href="#manuals"><span aria-hidden="true" class="octicon octicon-link"></span></a>Manuals</h1>
<ul>
<li>
<a href="https://nixos.org/nixos/manual" rel="nofollow">NixOS Manual</a> - how to install, configure, and maintain a purely-functional Linux distribution</li>
<li>
<a href="https://nixos.org/nixpkgs/manual/" rel="nofollow">Nixpkgs Manual</a> - contributing to Nixpkgs and using programming-language-specific Nix expressions</li>
<li>
<a href="https://nixos.org/nix/manual" rel="nofollow">Nix Package Manager Manual</a> - how to write Nix expressions (programs), and how to use Nix command line tools</li>
</ul>
<h1><a id="user-content-community" class="anchor" aria-hidden="true" tabindex="-1" href="#community"><span aria-hidden="true" class="octicon octicon-link"></span></a>Community</h1>
<ul>
<li><a href="https://discourse.nixos.org/" rel="nofollow">Discourse Forum</a></li>
<li><a href="https://matrix.to/#/#community:nixos.org" rel="nofollow">Matrix Chat</a></li>
<li><a href="https://weekly.nixos.org/" rel="nofollow">NixOS Weekly</a></li>
<li><a href="https://nixos.wiki/" rel="nofollow">Community-maintained wiki</a></li>
<li>
<a href="https://nixos.wiki/wiki/Get_In_Touch#Chat" rel="nofollow">Community-maintained list of ways to get in touch</a> (Discord, Telegram, IRC, etc.)</li>
</ul>
<h1><a id="user-content-other-project-repositories" class="anchor" aria-hidden="true" tabindex="-1" href="#other-project-repositories"><span aria-hidden="true" class="octicon octicon-link"></span></a>Other Project Repositories</h1>
<p>The sources of all official Nix-related projects are in the <a href="https://github.com/NixOS/">NixOS
organization on GitHub</a>. Here are some of
the main ones:</p>
<ul>
<li>
<a href="https://github.com/NixOS/nix">Nix</a> - the purely functional package manager</li>
<li>
<a href="https://github.com/NixOS/nixops">NixOps</a> - the tool to remotely deploy NixOS machines</li>
<li>
<a href="https://github.com/NixOS/nixos-hardware">nixos-hardware</a> - NixOS profiles to optimize settings for different hardware</li>
<li>
<a href="https://github.com/NixOS/rfcs">Nix RFCs</a> - the formal process for making substantial changes to the community</li>
<li>
<a href="https://github.com/NixOS/nixos-homepage">NixOS homepage</a> - the <a href="https://nixos.org" rel="nofollow">NixOS.org</a> website</li>
<li>
<a href="https://github.com/NixOS/hydra">hydra</a> - our continuous integration system</li>
<li>
<a href="https://github.com/NixOS/nixos-artwork">NixOS Artwork</a> - NixOS artwork</li>
</ul>
<h1><a id="user-content-continuous-integration-and-distribution" class="anchor" aria-hidden="true" tabindex="-1" href="#continuous-integration-and-distribution"><span aria-hidden="true" class="octicon octicon-link"></span></a>Continuous Integration and Distribution</h1>
<p>Nixpkgs and NixOS are built and tested by our continuous integration
system, <a href="https://hydra.nixos.org/" rel="nofollow">Hydra</a>.</p>
<ul>
<li><a href="https://hydra.nixos.org/jobset/nixos/trunk-combined" rel="nofollow">Continuous package builds for unstable/master</a></li>
<li><a href="https://hydra.nixos.org/jobset/nixos/release-23.05" rel="nofollow">Continuous package builds for the NixOS 23.05 release</a></li>
<li><a href="https://hydra.nixos.org/job/nixos/trunk-combined/tested#tabs-constituents" rel="nofollow">Tests for unstable/master</a></li>
<li><a href="https://hydra.nixos.org/job/nixos/release-23.05/tested#tabs-constituents" rel="nofollow">Tests for the NixOS 23.05 release</a></li>
</ul>
<p>Artifacts successfully built with Hydra are published to cache at
<a href="https://cache.nixos.org/" rel="nofollow">https://cache.nixos.org/</a>. When successful build and test criteria are
met, the Nixpkgs expressions are distributed via <a href="https://nixos.org/manual/nix/stable/package-management/channels.html" rel="nofollow">Nix
channels</a>.</p>
<h1><a id="user-content-contributing" class="anchor" aria-hidden="true" tabindex="-1" href="#contributing"><span aria-hidden="true" class="octicon octicon-link"></span></a>Contributing</h1>
<p>Nixpkgs is among the most active projects on GitHub. While thousands
of open issues and pull requests might seem a lot at first, it helps
consider it in the context of the scope of the project. Nixpkgs
describes how to build tens of thousands of pieces of software and implements a
Linux distribution. The <a href="https://github.com/NixOS/nixpkgs/pulse">GitHub Insights</a>
page gives a sense of the project activity.</p>
<p>Community contributions are always welcome through GitHub Issues and
Pull Requests.</p>
<p>For more information about contributing to the project, please visit
the <a href="https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md">contributing page</a>.</p>
<h1><a id="user-content-donations" class="anchor" aria-hidden="true" tabindex="-1" href="#donations"><span aria-hidden="true" class="octicon octicon-link"></span></a>Donations</h1>
<p>The infrastructure for NixOS and related projects is maintained by a
nonprofit organization, the <a href="https://nixos.org/nixos/foundation.html" rel="nofollow">NixOS
Foundation</a>. To ensure the
continuity and expansion of the NixOS infrastructure, we are looking
for donations to our organization.</p>
<p>You can donate to the NixOS foundation through <a href="https://nixos.org/donate.html" rel="nofollow">SEPA bank
transfers</a> or by using Open Collective:</p>
<p><a href="https://opencollective.com/nixos#support" rel="nofollow"><img src="https://camo.githubusercontent.com/14456c32395243bcef3592725188675391c305d2f168505661471cdd55f27311/68747470733a2f2f6f70656e636f6c6c6563746976652e636f6d2f6e69786f732f74696572732f737570706f727465722e7376673f77696474683d383930" data-canonical-src="https://opencollective.com/nixos/tiers/supporter.svg?width=890" style="max-width: 100%;"></a></p>
<h1><a id="user-content-license" class="anchor" aria-hidden="true" tabindex="-1" href="#license"><span aria-hidden="true" class="octicon octicon-link"></span></a>License</h1>
<p>Nixpkgs is licensed under the <a href="COPYING">MIT License</a>.</p>
<p>Note: MIT license does not apply to the packages built by Nixpkgs,
merely to the files in this repository (the Nix expressions, build
scripts, NixOS modules, etc.). It also might not apply to patches
included in Nixpkgs, which may be derivative works of the packages to
which they apply. The aforementioned artifacts are all covered by the
licenses of the respective packages.</p>
