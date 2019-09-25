describe Fastlane::Actions::UploadSymbolsToAppmetricaAction do
  describe 'upload dsym' do
    it "fails with no 'helper' path" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
          upload_symbols_to_appmetrica
        end").runner.execute(:test)
      end.to raise_error("Failed to find 'helper' binary. Install YandexMobileMetrica 3.8.0 pod or higher. "\
          "You may specify the location of the binary by using the binary_path option")
    end
  end
end
