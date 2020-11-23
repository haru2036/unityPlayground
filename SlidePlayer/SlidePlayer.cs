
using UdonSharp;
using UnityEngine;
using UnityEngine.UI;
using VRC.SDKBase;
using VRC.Udon;
using VRC.SDK3.Components;
using VRC.SDK3.Video.Components;
using VRC.SDK3.Video.Components.AVPro;
using VRC.SDK3.Video.Components.Base;
using VRC.SDK3.Components.Video;

[AddComponentMenu("SlidePlayer")]
public class SlidePlayer : UdonSharpBehaviour
{
    [UdonSynced]
    VRCUrl _syncedURL;
    [UdonSynced]
    int _page = 0;

    string localURL = "";

    public VRCUrlInputField inputField;
    public Text urlText;

    [Header("Video Player References")]
    public VRCUnityVideoPlayer unityVideoPlayer;
    int localPage = 0;

    public float timeSpan = 1f;

    void Start()
    {
        
    }

    public void OnURLChanged(){
        VRCUrl url = inputField.GetUrl();
        if(url != null){
            Debug.Log("OnURLChanged url: " + url.ToString());
        }
        if (!Networking.IsOwner(gameObject))
        {
            Debug.Log("Take ownership");
            Networking.SetOwner(Networking.LocalPlayer, gameObject);
        }
        _syncedURL = url;
        unityVideoPlayer.LoadURL(url);
    }

    public void OnNextSlideButtonClick()
    {
        if(Networking.IsOwner(gameObject))
        {
            Debug.Log("OnNextSlideButtonClick as owner");
            _page++;
            localPage = _page;
            ChangeVideoPosition(localPage);
        }
    }

    public void OnPrevSlideButtonClick()
    {
        if (Networking.IsOwner(gameObject))
        {
            Debug.Log("OnPrevSlideButtonClick as owner");
            _page--;
            localPage = _page;
            ChangeVideoPosition(localPage);
        }
    }

    private void ChangeVideoPosition(int pageNumber)
    {
        Debug.Log("ChangeVideoPosition: " + pageNumber);
        unityVideoPlayer.SetTime((float)pageNumber * timeSpan);
    }

    public override void OnDeserialization()
    {
        Debug.Log("OnDeserialization");
        if(!Networking.IsOwner(gameObject)){
            if(_page != localPage){
                localPage = _page;
                ChangeVideoPosition(localPage);
            }
            if(_syncedURL != null){
                if(_syncedURL.ToString() != localURL)
                {
                    Debug.Log("Local url: " + localURL);
                    Debug.Log("Synced url: " + _syncedURL.ToString());
                    localURL = _syncedURL.ToString();
                    unityVideoPlayer.LoadURL(_syncedURL);
                }
            }
        }
    }

    public override void OnVideoReady()
    {
        Debug.Log("OnVideoReady");
        if(!Networking.IsOwner(gameObject)){
            ChangeVideoPosition(localPage);
        }
    }

}
