<?php

declare(strict_types=1);

namespace Linedubbed\Runner\Core;

final class GitHelper
{
    public static function determineVersion(string $path): string
    {
        $tag = self::determineTag($path);
        if ($tag !== null) {
            return $tag;
        }

        $commit = self::determineCommit($path);
        if ($commit !== null) {
            return $commit;
        }

        return 'dev';
    }

    private static function determineTag(string $path): ?string
    {
        return self::executeAndTrim('git describe --tags', $path);
    }

    private static function determineCommit(string $path): ?string
    {
        return self::executeAndTrim('git rev-parse --short HEAD', $path);
    }

    private static function executeAndTrim(string $cmd, string $path): ?string
    {
        $fd = [
            ['pipe', 'r'],
            ['pipe', 'w'],
            ['pipe', 'w'],
        ];
        $p = proc_open($cmd, $fd, $pipes, $path);
        if ($p === false) {
            return null;
        }
        fclose($pipes[0]);

        $result = stream_get_contents($pipes[1]);
        fclose($pipes[1]);
        fclose($pipes[2]);

        $status = proc_close($p);
        if ($status !== 0) {
            return null;
        }

        return trim($result);
    }
}
