<?php

declare(strict_types=1);

use Linedubbed\Runner\GitHelper;
use Symfony\Component\Console\Application;

require __DIR__ . '/../vendor/autoload.php';

function main(): int
{
    $version = GitHelper::determineVersion(__DIR__ . '/..');
    $app = new Application('lineDUBbed/runner', $version);

    $app->add(new \Linedubbed\Runner\Commands\DaemonCommand());
    $app->add(new \Linedubbed\Runner\Commands\UpgradeCommand());

    try {
        return $app->run();
    } catch (Exception $ex) {
        echo 'Unhandled Exception: ', $ex->getMessage();
        return 1;
    }
}
