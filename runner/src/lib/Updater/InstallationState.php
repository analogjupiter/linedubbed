<?php

declare(strict_types=1);

namespace Linedubbed\Runner\Updater;

final class InstallationState
{
    public function __construct(
        private string $installationStateDir,
    ) {
    }

    public function directoryExists(): bool
    {
        return file_exists($this->installationStateDir);
    }

    public function sentinelFileExists(): bool
    {
        return file_exists($this->installationStateDir . '/is-installed');
    }
}
