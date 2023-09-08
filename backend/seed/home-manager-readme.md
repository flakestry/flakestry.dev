<h1><a id="user-content-home-manager-using-nix" class="anchor" aria-hidden="true" tabindex="-1" href="#home-manager-using-nix"><span aria-hidden="true" class="octicon octicon-link"></span></a>Home Manager using Nix</h1>
<p>This project provides a basic system for managing a user environment
using the <a href="https://nixos.org/explore.html" rel="nofollow">Nix</a> package manager together with the Nix libraries
found in <a href="https://github.com/NixOS/nixpkgs">Nixpkgs</a>. It allows declarative configuration of user
specific (non global) packages and dotfiles.</p>
<h2><a id="user-content-usage" class="anchor" aria-hidden="true" tabindex="-1" href="#usage"><span aria-hidden="true" class="octicon octicon-link"></span></a>Usage</h2>
<p>Before attempting to use Home Manager please read the warning below.</p>
<p>For a systematic overview of Home Manager and its available options,
please see</p>
<ul>
<li>the <a href="https://nix-community.github.io/home-manager/index.html" rel="nofollow">Home Manager manual</a>,</li>
<li>the <a href="https://nix-community.github.io/home-manager/options.html" rel="nofollow">Home Manager configuration options</a>, and</li>
<li>the 3rd party <a href="https://mipmip.github.io/home-manager-option-search/" rel="nofollow">Home Manager option search</a>.</li>
</ul>
<p>If you would like to contribute to Home Manager
then please have a look at the <a href="https://nix-community.github.io/home-manager/#ch-contributing" rel="nofollow">contributing</a> chapter of the manual.</p>
<h2><a id="user-content-releases" class="anchor" aria-hidden="true" tabindex="-1" href="#releases"><span aria-hidden="true" class="octicon octicon-link"></span></a>Releases</h2>
<p>Home Manager is developed against <code>nixpkgs-unstable</code> branch, which
often causes it to contain tweaks for changes/packages not yet
released in stable NixOS. To avoid breaking users' configurations,
Home Manager is released in branches corresponding to NixOS releases
(e.g. <code>release-23.05</code>). These branches get fixes, but usually not new
modules. If you need a module to be backported, then feel free to open
an issue.</p>
<h2><a id="user-content-words-of-warning" class="anchor" aria-hidden="true" tabindex="-1" href="#words-of-warning"><span aria-hidden="true" class="octicon octicon-link"></span></a>Words of warning</h2>
<p>Unfortunately, it is quite possible to get difficult to understand
errors when working with Home Manager. You should therefore be
comfortable using the Nix language and the various tools in the Nix
ecosystem.</p>
<p>If you are not very familiar with Nix but still want to use Home
Manager then you are strongly encouraged to start with a small and
very simple configuration and gradually make it more elaborate as you
learn.</p>
<p>In some cases Home Manager cannot detect whether it will overwrite a
previous manual configuration. For example, the Gnome Terminal module
will write to your dconf store and cannot tell whether a configuration
that it is about to be overwritten was from a previous Home Manager
generation or from manual configuration.</p>
<p>Home Manager targets <a href="https://nixos.org/" rel="nofollow">NixOS</a> unstable and NixOS version 23.05 (the
current stable version), it may or may not work on other Linux
distributions and NixOS versions.</p>
<p>Also, the <code>home-manager</code> tool does not explicitly support rollbacks at
the moment so if your home directory gets messed up you'll have to fix
it yourself. See the <a href="https://nix-community.github.io/home-manager/index.html#sec-usage-rollbacks" rel="nofollow">rollbacks</a> section for instructions on how to
manually perform a rollback.</p>
<p>Now when your expectations have been built up and you are eager to try
all this out you can go ahead and read the rest of this text.</p>
<h2><a id="user-content-contact" class="anchor" aria-hidden="true" tabindex="-1" href="#contact"><span aria-hidden="true" class="octicon octicon-link"></span></a>Contact</h2>
<p>You can chat with us on IRC in the channel <a href="https://webchat.oftc.net/?channels=home-manager" rel="nofollow">#home-manager</a> on <a href="https://oftc.net/" rel="nofollow">OFTC</a>.
There is also a <a href="https://matrix.to/#/#hm:rycee.net" rel="nofollow">Matrix room</a>,
which is bridged to the IRC channel.</p>
<h2><a id="user-content-installation" class="anchor" aria-hidden="true" tabindex="-1" href="#installation"><span aria-hidden="true" class="octicon octicon-link"></span></a>Installation</h2>
<p>Home Manager can be used in three primary ways:</p>
<ol>
<li>
<p>Using the standalone <code>home-manager</code> tool. For platforms other than
NixOS and Darwin, this is the only available choice. It is also
recommended for people on NixOS or Darwin that want to manage their
home directory independently of the system as a whole. See
<a href="https://nix-community.github.io/home-manager/index.html#sec-install-standalone" rel="nofollow">Standalone installation</a> in the manual
for instructions on how to perform this installation.</p>
</li>
<li>
<p>As a module within a NixOS system configuration. This allows the
user profiles to be built together with the system when running
<code>nixos-rebuild</code>. See <a href="https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module" rel="nofollow">NixOS module installation</a> in the manual for a description of this setup.</p>
</li>
<li>
<p>As a module within a <a href="https://github.com/LnL7/nix-darwin">nix-darwin</a> system configuration. This
allows the user profiles to be built together with the system when
running <code>darwin-rebuild</code>. See <a href="https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module" rel="nofollow">nix-darwin module
installation</a> in the manual for a
description of this setup.</p>
</li>
</ol>
<p>Home Manager provides both the channel-based setup and the flake-based one.
See <a href="https://nix-community.github.io/home-manager/index.html#ch-nix-flakes" rel="nofollow">Nix Flakes</a> for a description of the flake-based setup.</p>
<h2><a id="user-content-translations" class="anchor" aria-hidden="true" tabindex="-1" href="#translations"><span aria-hidden="true" class="octicon octicon-link"></span></a>Translations</h2>
<p>Home Manager has basic support for internationalization through
<a href="https://www.gnu.org/software/gettext/" rel="nofollow">gettext</a>. The translations are
hosted by <a href="https://weblate.org/" rel="nofollow">Weblate</a>. If you would like to
contribute to the translation effort then start by going to the
<a href="https://hosted.weblate.org/engage/home-manager/" rel="nofollow">Home Manager Weblate project</a>.</p>
<a href="https://hosted.weblate.org/engage/home-manager/" rel="nofollow">
<img src="https://camo.githubusercontent.com/e76795e0e16e896e3a87f1e876d3c4f9c9b679bd6789a2d2ab25efc6c04d432d/68747470733a2f2f686f737465642e7765626c6174652e6f72672f776964676574732f686f6d652d6d616e616765722f2d2f6d756c74692d6175746f2e737667" alt="Translation status" data-canonical-src="https://hosted.weblate.org/widgets/home-manager/-/multi-auto.svg" style="max-width: 100%;">
</a>
<h2><a id="user-content-license" class="anchor" aria-hidden="true" tabindex="-1" href="#license"><span aria-hidden="true" class="octicon octicon-link"></span></a>License</h2>
<p>This project is licensed under the terms of the <a href="LICENSE">MIT license</a>.</p>
