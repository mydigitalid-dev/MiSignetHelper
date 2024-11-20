@testable import MiSignetHelper
import Testing

@MainActor
@Test("This will always return false as fresh simulator does not pre installed with signet clinet")
func mainActorFunction() {
    #expect(MiSignetHelper.isMiSignetInstalled() == false)
}
