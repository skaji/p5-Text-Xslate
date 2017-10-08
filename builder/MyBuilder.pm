package builder::MyBuilder;
use strict;
use warnings;
use base 'Module::Build::XSUtil';

sub new {
    my ($class, %args) = @_;
    $class->SUPER::new(
        %args,
        c_source => ['src'],
        cc_warnings => 1,
        generate_ppport_h => 'src/ppport.h',
        generate_xshelper_h => 'src/xshelper.h',
        xs_files => { 'src/Text-Xslate.xs' => 'lib/Text/Xslate.xs' },
    );
}

sub ACTION_build {
    my ($self, @args) = @_;

    my @cmd = (
        "$^X tool/opcode.PL src/xslate_opcode.inc > src/xslate_ops.h",
        "$^X tool/opcode_for_pp.PL src/xslate_opcode.inc > lib/Text/Xslate/PP/Const.pm",
    );
    for my $cmd (@cmd) {
        $self->log_info("$cmd\n");
        system $cmd;
    }

    if (!$self->pureperl_only && !$self->up_to_date("src/xslate_methods.xs", "src/xslate_methods.c")) {
        $self->compile_xs("src/xslate_methods.xs", outfile => "src/xslate_methods.c");
    }

    $self->SUPER::ACTION_build(@args);
}

sub ACTION_test {
    my ($self, @args) = @_;
    local $ENV{PERL_ONLY} = 1 if $self->pureperl_only;
    $self->SUPER::ACTION_test(@args);
}

1;
