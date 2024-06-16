<?php

declare(strict_types=1);

use Psr\Container\ContainerInterface as Container;

return [
    'dir.installation_state' => __DIR__ . '/../.local',
    'dir.migrations' => __DIR__ . '/migrations',

    \Linedubbed\Runner\Updater\InstallationState::class => function (Container $c) {
        return new \Linedubbed\Runner\Updater\InstallationState($c->get('dir.installation_state'));
    },

    \Linedubbed\Runner\Updater\SystemMigration\Migrator::class => function (Container $c) {
        return new \Linedubbed\Runner\Updater\SystemMigration\Migrator(
            $c->get('dir.migrations'),
            $c->get('dir.installation_state'),
        );
    },
];
