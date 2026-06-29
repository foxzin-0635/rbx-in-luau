-- Main configuration for rbx-api-luau
return {
  -- Inaccessible Security Contexts simulation settings
  SimulatedIdentityHacks = {
    RobloxSecurity = {
      CanUse = false,
      IdentityLevel = -1
    },
    NotAccessibleSecurity = {
      CanUse = false,
      IdentityLevel = -1
    }
  },
  -- Bypass the errors from getting an normally inaccessible class
  CanImportAnyClass = false,
  -- Prints the current path that githubRequire is working on.
  debugOutputRequirePaths = true
}