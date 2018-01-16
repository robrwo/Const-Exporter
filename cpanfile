requires "Carp" => "0";
requires "Const::Fast" => "0";
requires "Exporter" => "0";
requires "Package::Stash" => "0";
requires "Scalar::Util" => "0";
requires "perl" => "v5.10.0";
requires "strict" => "0";
requires "warnings" => "0";
recommends "Package::Stash::XS" => "0";
recommends "Storable" => "0";

on 'test' => sub {
  requires "File::Spec" => "0";
  requires "Hash::Objectify" => "0";
  requires "JSON::PP" => "2.00";
  requires "Module::Metadata" => "0";
  requires "Path::Tiny" => "0.004";
  requires "Test::More" => "0";
  requires "Test::Most" => "0";
  requires "Time::Piece" => "1.16";
  requires "Time::Seconds" => "0";
  requires "if" => "0";
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
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