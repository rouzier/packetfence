package pf::constants::filters;

use strict;
use warnings;
use base qw(Exporter);
use Readonly;

our @EXPORT_OK = qw(%FILTERS_IDENTIFIERS %CONFIGSTORE_MAP %ENGINE_MAP);

our %FILTERS_IDENTIFIERS = (
    VLAN_FILTERS => "vlan-filters",
    RADIUS_FILTERS => "radius-filters",
    APACHE_FILTERS => "apache-filters",
);

our %CONFIGSTORE_MAP = (
    $FILTERS_IDENTIFIERS{VLAN_FILTERS}   => pf::ConfigStore::VlanFilters->new,
    $FILTERS_IDENTIFIERS{RADIUS_FILTERS} => pf::ConfigStore::RadiusFilters->new,
    $FILTERS_IDENTIFIERS{APACHE_FILTERS} => pf::ConfigStore::ApacheFilters->new,
);

our %ENGINE_MAP = (
    $FILTERS_IDENTIFIERS{VLAN_FILTERS}   => "FilterEngine::VlanScopes",
    $FILTERS_IDENTIFIERS{RADIUS_FILTERS} => "FilterEngine::RadiusScopes",
    $FILTERS_IDENTIFIERS{APACHE_FILTERS} => $CONFIGSTORE_MAP{"apache-filters"}->pfconfigNamespace,
);

1;
