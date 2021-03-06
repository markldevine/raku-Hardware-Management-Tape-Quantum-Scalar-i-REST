need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
use     LibXML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionCapabilities:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                        $names-checked = False;
my      Bool                                        $analyzed = False;
my      Lock                                        $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config   $.config is required;
has     Bool                                        $.initialized = False;
has     Bool                                        $.loaded = False;
has     LibXML::Element                             $.xml is required;
has     Str                                         $.DynamicLogicalPartitionIOCapable;
has     Str                                         $.DynamicLogicalPartitionMemoryCapable;
has     Str                                         $.DynamicLogicalPartitionVIOSCapable;
has     Str                                         $.DynamicLogicalPartitionProcessorCapable;
has     Str                                         $.InternalAndExternalIntrusionDetectionCapable;
has     Str                                         $.ResourceMonitoringControlOperatingSystemShutdownCapable;

method  xml-name-exceptions () { return set <Metadata>; }

submethod TWEAK {
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $proceed-with-name-check = False;
    my $proceed-with-analyze    = False;
    $lock.protect({
        if !$analyzed           { $proceed-with-analyze    = True; $analyzed      = True; }
        if !$names-checked      { $proceed-with-name-check = True; $names-checked = True; }
    });
    self.etl-node-name-check    if $proceed-with-name-check;
    self.init;
    self.analyze                if $proceed-with-analyze;
    self;
}

method init () {
    return self             if $!initialized;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self                                                 if $!loaded;
    self.config.diag.post:                                      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!DynamicLogicalPartitionIOCapable                          = self.etl-text(:TAG<DynamicLogicalPartitionIOCapable>,                         :$!xml);
    $!DynamicLogicalPartitionMemoryCapable                      = self.etl-text(:TAG<DynamicLogicalPartitionMemoryCapable>,                     :$!xml);
    $!DynamicLogicalPartitionVIOSCapable                        = self.etl-text(:TAG<DynamicLogicalPartitionVIOSCapable>,                       :$!xml);
    $!DynamicLogicalPartitionProcessorCapable                   = self.etl-text(:TAG<DynamicLogicalPartitionProcessorCapable>,                  :$!xml);
    $!InternalAndExternalIntrusionDetectionCapable              = self.etl-text(:TAG<InternalAndExternalIntrusionDetectionCapable>,             :$!xml);
    $!ResourceMonitoringControlOperatingSystemShutdownCapable   = self.etl-text(:TAG<ResourceMonitoringControlOperatingSystemShutdownCapable>,  :$!xml);
    $!xml                                                       = Nil;
    $!loaded                                                    = True;
    self;
}

=finish
