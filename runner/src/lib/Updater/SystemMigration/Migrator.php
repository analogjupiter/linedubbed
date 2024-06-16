<?php

declare(strict_types=1);

namespace Linedubbed\Runner\Updater\SystemMigration;

use DirectoryIterator;
use Exception;
use Symfony\Component\Console\Output\OutputInterface;

final class Migrator
{
    private string $migrationLevelFile;

    public function __construct(
        private readonly string $migrationsDir,
        string $installationStateDir,
    ) {
        $this->migrationLevelFile = $installationStateDir . '/migration-level';
    }

    public function getCurrentLevel(): string
    {
        if (!file_exists($this->migrationLevelFile)) {
            return '00000000-000000';
        }

        $level = file_get_contents($this->migrationLevelFile);
        return trim($level);
    }

    /**
     * @return Migration[]
     * @throws Exception
     */
    public function getApplicableMigrations(): array
    {
        $currentLevel = Migration::parse($this->getCurrentLevel());

        $result = [];

        $dir = new DirectoryIterator($this->migrationsDir);
        foreach ($dir as $file) {
            var_dump($file->getPathname());
            if (!$file->isFile()) {
                continue;
            }

            $migration = new Migration($file->getPathname());

            // skip past migrations
            if ($migration->getLevel() < $currentLevel) {
                continue;
            }

            $result[] = $migration;
        }

        usort($result, function (Migration $a, Migration $b) {
            return $b->getLevel() <=> $a->getLevel();
        });

        return $result;
    }

    /**
     * @throws MigrationFailure
     * @throws Exception
     */
    public function applyMigrations(OutputInterface $log): string
    {
        $currentLevel = $this->getCurrentLevel();
        $applicableMigrations = $this->getApplicableMigrations();

        foreach ($applicableMigrations as $migration) {
            $log->writeln(sprintf('Applying migration `%s`.', $migration->getLevelString()));
            $this->runMigration($migration);

            $currentLevel = $migration->getLevelString();
            $this->saveCurrentLevel($currentLevel);
        }

        return $currentLevel;
    }

    /**
     * @throws Exception
     * @throws MigrationFailure
     */
    private function runMigration(Migration $migration): void
    {
        $fd = [
            ['pipe', 'r'],
            ['pipe', 'w'],
            ['pipe', 'w'],
        ];
        $p = proc_open($migration->getPath(), $fd, $pipes, null);
        if ($p === false) {
            throw new Exception(sprintf('Unable to run migration `%s`.', $migration->getPath()));
        }
        fclose($pipes[0]);

        $stdout = stream_get_contents($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);

        fclose($pipes[1]);
        fclose($pipes[2]);

        $status = proc_close($p);
        if ($status !== 0) {
            throw new MigrationFailure($migration, $status, $stdout, $stderr);
        }
    }

    /**
     * @throws Exception
     */
    private function saveCurrentLevel(string $currentLevel): void
    {
        $saved = file_put_contents($this->migrationLevelFile, $currentLevel);
        if ($saved === false) {
            throw new Exception('Could not save migration level.');
        }
    }
}
