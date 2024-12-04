
# MiSignetHelper

## Proof of concept version 1

### Fetures

- MiSignetHelper is now a saperate project with its own test environment

- Package now comes with versioning control in git for managable feature release or fix

- auto distribution of package update via git repo

- added new method to toggle debug log

- disabled unused functions

  

### Notes

- MiSignetHelper used by Mi-Signet is different from integrator's

  

### TODOs
- [x] Convert to Swift package Manager in git

- [x] Hide unused API

- [x] New debug mode toggle

- [ ] Error closure is entirely when plist is misconfigured with no data or data was not supplied in request methods (impossible. data not nullable). Maybe return proper error or just note in doc?

