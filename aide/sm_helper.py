import sagemaker, boto3

def get_sagemaker_session(local_download_dir) -> sagemaker.Session:
    """Return the SageMaker session."""

    sagemaker_client = boto3.client(
        service_name="sagemaker", region_name=boto3.Session().region_name
    )

    session_settings = sagemaker.session_settings.SessionSettings(
        local_download_dir=local_download_dir
    )

    # the unit test will ensure you do not commit this change
    session = sagemaker.session.Session(
        sagemaker_client=sagemaker_client, settings=session_settings
    )

    return session