<?php

declare(strict_types=1);

namespace Linedubbed\Runner\Updater\SystemMigration;

use Exception;

final class MigrationFailure extends Exception
{
    public function __construct(
        public Migration $migration,
        public int $statusCode,
        public string $stdout,
        public string $stderr,
    ) {
        parent::__construct('An error occurred during the execution of a migration.');
    }
}
