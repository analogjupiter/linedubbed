<?php

declare(strict_types=1);

namespace Linedubbed\Runner\Commands;

use Exception;
use Linedubbed\Runner\Updater\InstallationState;
use Linedubbed\Runner\Updater\SystemMigration\MigrationFailure;
use Linedubbed\Runner\Updater\SystemMigration\Migrator;
use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

#[AsCommand(
    name: 'ldr:upgrade',
)]
final class UpgradeCommand extends Command
{
    public function __construct(
        private readonly Migrator $migrator,
        private readonly InstallationState $installationState,
    ) {
        parent::__construct();
    }

    protected function configure(): void
    {
        $this
            ->setDescription('Migrates the application setup to the installed version.')
            ->setHelp('This command allows you to migrate your installation to the installed version.');
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        if (!$this->installationState->sentinelFileExists()) {
            $output->writeln('<error>App is not installed on this system.</error>');
            return Command::FAILURE;
        }

        $current = $this->migrator->getCurrentLevel();
        $output->writeln('Current migration level: ' . $current);

        try {
            $current = $this->migrator->applyMigrations($output);
        } catch (MigrationFailure $ex) {
            $output->writeln('<error>' . $ex->getMessage() . '</error>');
            $output->writeln('== Details ==');
            $output->writeln('Migration: ' . $ex->migration->getPath());
            $output->writeln('Status Code: ' . $ex->statusCode);
            $output->writeln('== stdout ==');
            $output->writeln($ex->stdout);
            $output->writeln('== stderr ==');
            $output->writeln($ex->stderr);
            $output->writeln('== End of Details ==');
            return Command::FAILURE;
        } catch (Exception $ex) {
            $output->writeln('<error>' . $ex->getMessage() . '</error>');
            return Command::FAILURE;
        }

        $output->writeln('<info>Migrated installation to: ' . $current . '</info>');

        return Command::SUCCESS;
    }
}
