# This file is generated by Dist::Zilla::Plugin::CPANFile v6.032
# Do not edit this file directly. To change prereqs, edit the `dist.ini` file.

requires "Carp" => "0";
requires "Const::Fast" => "0";
requires "Exporter" => "5.57";
requires "List::Util" => "1.56";
requires "Package::Stash" => "0";
requires "Ref::Util" => "0";
requires "perl" => "v5.14.0";
requires "warnings" => "0";
recommends "List::SomeUtils::XS" => "0";
recommends "Package::Stash::XS" => "0";
recommends "Ref::Util::XS" => "0";
recommends "Storable" => "3.05";

on 'build' => sub {
  requires "ExtUtils::MakeMaker" => "7.22";
  requires "Module::Metadata" => "1.000015";
};

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "Hash::Objectify" => "0";
  requires "Module::Metadata" => "1.000015";
  requires "Sub::Identify" => "0.06";
  requires "Test::More" => "0";
  requires "Test::Most" => "0";
  requires "if" => "0";
  requires "lib" => "0";
  requires "strict" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CVE" => "0.08";
  requires "Test::DistManifest" => "0";
  requires "Test::EOF" => "0";
  requires "Test::EOL" => "0";
  requires "Test::Kwalitee" => "1.21";
  requires "Test::MinimumVersion" => "0";
  requires "Test::More" => "0.88";
  requires "Test::NoTabs" => "0";
  requires "Test::Perl::Critic" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "Test::Pod::LinkCheck" => "0";
  requires "Test::Portability::Files" => "0";
  requires "Test::TrailingSpace" => "0.0203";
};
