<?php

declare(strict_types=1);

use Linedubbed\Runner\Core\GitHelper;
use Symfony\Component\Console\Application;

require __DIR__ . '/../vendor/autoload.php';

function main(): int
{
    $diConfig = require __DIR__ . '/di.php';
    $container = new \DI\Container($diConfig);

    $version = GitHelper::determineVersion(__DIR__ . '/..');
    $app = new Application('lineDUBbed/runner', $version);

    try {
        $app->add($container->get(\Linedubbed\Runner\Commands\DaemonCommand::class));
        $app->add($container->get(\Linedubbed\Runner\Commands\UpgradeCommand::class));

        return $app->run();
    } catch (Exception $ex) {
        echo 'Unhandled Exception: ', $ex->getMessage();
        return 1;
    }
}
