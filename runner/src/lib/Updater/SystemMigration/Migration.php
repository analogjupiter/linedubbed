<?php

declare(strict_types=1);

namespace Linedubbed\Runner\Updater\SystemMigration;

use DateTimeImmutable;
use Exception;

final class Migration
{
    public const format = 'Ymd-His';

    private ?DateTimeImmutable $level = null;

    public function __construct(
        private string $path,
    ) {
    }

    public function getLevel(): DateTimeImmutable
    {
        if ($this->level === null) {
            $this->level = $this->parse($this->path);
        }

        return $this->level;
    }

    public function getLevelString(): string
    {
        return $this->level->format(self::format);
    }

    public function getPath(): string
    {
        return $this->path;
    }

    public static function parse(string $path): DateTimeImmutable
    {
        $name = basename($path);

        $idxSep = strpos($name, '_');
        if ($idxSep === false) {
            $idxSep = strlen($name);
        }

        $levelPart = substr($name, 0, $idxSep);
        $level = DateTimeImmutable::createFromFormat(self::format, $levelPart);
        if ($level === false) {
            throw new Exception(sprintf('Invalid migration file name `%s`.', $name));
        }

        return $level;
    }
}
