# Cerebral

## Introduction
Cerebral occupies a single space in memory on the server. Instead of initializing Cerebral in every file, it is initialized in its original module script.

```lau
-- src/init.lua

local Cerebral = {}

function Cerebral.New()
    -- initializing goodness
end

-- Some other methods

local out = Cerebral.New()
return out
```