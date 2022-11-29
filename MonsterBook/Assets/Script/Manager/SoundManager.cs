using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;



[System.Serializable]
public class StringAudioClip : SerializableDictionary<string, AudioClip> { }
[System.Serializable]
public class StringAudioClipArray : SerializableDictionary<string, AudioClip[]> { }

public class SoundManager : MonoBehaviour
{
    public static SoundManager Instance;

    [Serializable]
    struct Sound
    {
        public string name;
        public AudioClip[] clip;
    }

    [SerializeField] private GameObject soundPrefab;
    private AudioSource myAudio;
    [SerializeField] private AudioMixer mixer;
    
    [SerializeField] private Sound[] soundsList;    
    private Dictionary<string, AudioClip[]> soundDic = new Dictionary<string, AudioClip[]>();

    private Dictionary<int, GameObject> loopSoundDic = new Dictionary<int, GameObject>();


    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(this);
        }
        else
        {
            Destroy(gameObject);
        }
        myAudio = GetComponent<AudioSource>();
        myAudio.outputAudioMixerGroup = mixer.FindMatchingGroups("BGM")[0];
        myAudio.loop = true;

        for (int i = 0; i < soundsList.Length; i++)
        {
            soundDic.Add(soundsList[i].name, soundsList[i].clip);
        }
    }

    private void Start()
    {
        var global = Instance.mixer.FindMatchingGroups("Master")[0];
        global.audioMixer.SetFloat("GlobalVolume"
            , PlayerPrefs.GetFloat("GlobalVolume", 0));

        var bgm = Instance.mixer.FindMatchingGroups("BGM")[0];
        bgm.audioMixer.SetFloat("BGMVolume"
             , PlayerPrefs.GetFloat("BGMVolume", 0));

        var sfx = Instance.mixer.FindMatchingGroups("VFX")[0];
        sfx.audioMixer.SetFloat("VFXVolume"
             , PlayerPrefs.GetFloat("VFXVolume", 0));
    }

    public static AudioClip GetCurentBGM() { return Instance.myAudio.clip; }

    public static bool CheckCureentBGM(string name)
    {
        if (Instance.myAudio.clip == null) return false;

        return Instance.myAudio.clip == Instance.soundDic[name][0];
    }

    #region Base

    public static void ChangeGlobalVolume(float volume)
    {
        var global = Instance.mixer.FindMatchingGroups("Master")[0];
        global.audioMixer.SetFloat("GlobalVolume", volume);

        PlayerPrefs.SetFloat("GlobalVolume", volume);
    }
    public static void ChangeBGMVolume(float volume)
    {
        var bgm = Instance.mixer.FindMatchingGroups("BGM")[0];
        bgm.audioMixer.SetFloat("BGMVolume", volume);

        PlayerPrefs.SetFloat("BGMVolume", volume);
    }
    public static void ChangeSFXVolume(float volume)
    {
        var sfx = Instance.mixer.FindMatchingGroups("VFX")[0];
        sfx.audioMixer.SetFloat("VFXVolume", volume);

        PlayerPrefs.SetFloat("VFXVolume", volume);
    }


    public static void PlayBackGroundSound(string name)
    {
        if (!Instance.soundDic.ContainsKey(name)) return;
        Instance.StartCoroutine(Instance.SoundRoutine(name, 0));
    }

    public static void PlayBackGroundSound(string name, float time)
    {
        if (!Instance.soundDic.ContainsKey(name)) return;
        Instance.StartCoroutine(Instance.SoundRoutine(name, time));
    }

    public static void StopBGM(float speed = 2)
    {
        Instance.StartCoroutine(Instance.SoundStop(speed));
    }

    private IEnumerator SoundRoutine(string name, float delay)
    {
        yield return YieldInstructionCache.waitForSeconds(delay);
        var time = 0f;
        if (myAudio.clip != null)
        {                 
            while (myAudio.volume != 0)
            {
                time += Time.deltaTime / 2;
                myAudio.volume = Mathf.Lerp(1, 0, time);
                yield return YieldInstructionCache.waitForFixedUpdate;
            }            
        }
        time = 0f;
        myAudio.clip = soundDic[name][0];
        Instance.myAudio.Play();
        while (myAudio.volume != 1)
        {
            time += Time.deltaTime / 2;
            myAudio.volume = Mathf.Lerp(0, 1, time);
            yield return YieldInstructionCache.waitForFixedUpdate;
        }        
    }

    private IEnumerator SoundStop(float speed)
    {
        var time = 0f;
        while (myAudio.volume != 0)
        {
            time += Time.deltaTime / speed;
            myAudio.volume = Mathf.Lerp(1, 0, time);
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
        myAudio.clip = null;
    }

    public static void PlayVFXSound(string name, Vector3 pos, float min = 1, float max = 25)
    {
        if (!Instance.soundDic.ContainsKey(name)) return;
        GameObject sound = Instantiate(Instance.soundPrefab, new Vector3(pos.x, pos.y, CameraController.GetCameraPos().z), Quaternion.identity);
        sound.name = name;
        AudioSource audioS = sound.GetComponent<AudioSource>();                
        int rand = UnityEngine.Random.Range(0, Instance.soundDic[name].Length - 1);        
        audioS.clip = Instance.soundDic[name][rand];
        audioS.maxDistance = max;
        audioS.minDistance = min;                
        audioS.Play();
        var time = Instance.soundDic[name][rand].length;
        Destroy(sound, time);
    }

    public static void PlayVFXSound(string name, Vector3 pos, bool loop, float loopTime = 0)
    {
        if (!Instance.soundDic.ContainsKey(name)) return;
        GameObject sound = new GameObject(name);
        AudioSource audioS = sound.AddComponent<AudioSource>();
        audioS.outputAudioMixerGroup = Instance.mixer.FindMatchingGroups("VFX")[0];
        int rand = UnityEngine.Random.Range(0, Instance.soundDic[name].Length - 1);
        audioS.loop = loop;        
        audioS.clip = Instance.soundDic[name][rand];
        audioS.spatialBlend = 1f;
        audioS.maxDistance = 50;
        audioS.minDistance = 1;
        sound.transform.position = pos;
        audioS.Play();
        var time = loop ? loopTime : Instance.soundDic[name][rand].length;
        Destroy(sound, time);
    }
    
    public static int PlayVFXLoopSound(string name, Transform parent, float min = 1, float max = 25)
    {
        if (!Instance.soundDic.ContainsKey(name)) return -1;
        GameObject sound = Instantiate(Instance.soundPrefab, new Vector3(parent.position.x, parent.position.y, CameraController.GetCameraPos().z), Quaternion.identity, parent);
        sound.name = name;
        AudioSource audioS = sound.GetComponent<AudioSource>();
        int rand = UnityEngine.Random.Range(0, Instance.soundDic[name].Length - 1);
        audioS.clip = Instance.soundDic[name][rand];
        audioS.maxDistance = max;
        audioS.minDistance = min;
        audioS.loop = true;
        audioS.Play();
        Instance.loopSoundDic.Add(sound.GetInstanceID(), sound);
        return sound.GetInstanceID();
    }

    public static GameObject PlayVFXLoopSound_World(string name, Transform parent, float min = 1, float max = 25)
    {
        if (!Instance.soundDic.ContainsKey(name)) return null;
        GameObject sound = Instantiate(Instance.soundPrefab, new Vector3(parent.position.x, parent.position.y, CameraController.GetCameraPos().z), Quaternion.identity);
        sound.name = name;
        AudioSource audioS = sound.GetComponent<AudioSource>();
        int rand = UnityEngine.Random.Range(0, Instance.soundDic[name].Length - 1);
        audioS.clip = Instance.soundDic[name][rand];
        audioS.maxDistance = max;
        audioS.minDistance = min;
        audioS.loop = true;
        audioS.Play();
        return sound;        
    }

    public static void StopVFXLoopSound(int id)
    {
        if (!Instance.loopSoundDic.ContainsKey(id))
        {
            Debug.Log("sound를 찾을수없음");
            return;
        }
        Destroy(Instance.loopSoundDic[id]);
        Instance.loopSoundDic.Remove(id);
    }

    //public static void PlayVFXSound(string name, Vector3 pos, float minDis, float maxDis)
    //{
    //    if (Instance.soundList[name] == null) return;
    //    GameObject sound = new GameObject(name);
    //    sound.transform.position = pos;
    //    AudioSource audioS = sound.AddComponent<AudioSource>();
    //    audioS.outputAudioMixerGroup = Instance.mixer.FindMatchingGroups("VFX")[0];
    //    audioS.clip = Instance.soundList[name];
    //    audioS.spatialBlend = 1;
    //    audioS.maxDistance = maxDis;
    //    audioS.minDistance = minDis;
    //    audioS.Play();

    //    Destroy(sound, Instance.soundList[name].length);
    //}

    public static void PlayUISound(string name)
    {
        if (!Instance.soundDic.ContainsKey(name)) return;

        GameObject sound = new GameObject(name);
        AudioSource audioS = sound.AddComponent<AudioSource>();
        audioS.outputAudioMixerGroup = Instance.mixer.FindMatchingGroups("UI")[0];
        audioS.clip = Instance.soundDic[name][0];
        audioS.Play();

        Destroy(sound, Instance.soundDic[name][0].length);
    }

    public static void PlayerUIClick()
    {
        PlayUISound("ui_click_sfx");
    }

    //public static void PlayVFXSound(string name, Vector3 pos, float minDis, float maxDis, Transform parent)
    //{
    //    if (Instance.soundList[name] == null) return;
    //    GameObject sound = new GameObject(name);
    //    sound.transform.position = pos;
    //    sound.transform.SetParent(parent);
    //    AudioSource audioS = sound.AddComponent<AudioSource>();
    //    audioS.outputAudioMixerGroup = Instance.mixer.FindMatchingGroups("VFX")[0];
    //    audioS.clip = Instance.soundList[name];
    //    audioS.spatialBlend = 1;
    //    audioS.maxDistance = maxDis;
    //    audioS.minDistance = minDis;
    //    audioS.Play();

    //    Destroy(sound, Instance.soundList[name].length);
    //}

    #endregion

    #region Plus Pitch

    //public static void PlayBackGroundSound(string name, float pitch)
    //{
    //    if (Instance.soundList[name] == null) return;
    //    Instance.myAudio.clip = Instance.soundList[name];
    //    Instance.myAudio.pitch = pitch;
    //    Instance.myAudio.Play();
    //}

    //public static void PlayVFXSound(string name, Vector3 pos, float minDis, float maxDis, float pitch)
    //{
    //    if (Instance.soundList[name] == null) return;
    //    GameObject sound = new GameObject(name);
    //    sound.transform.position = pos;
    //    AudioSource audioS = sound.AddComponent<AudioSource>();
    //    audioS.outputAudioMixerGroup = Instance.mixer.FindMatchingGroups("VFX")[0];
    //    audioS.clip = Instance.soundList[name];
    //    audioS.pitch = pitch;
    //    audioS.spatialBlend = 1;
    //    audioS.maxDistance = maxDis;
    //    audioS.minDistance = minDis;
    //    audioS.Play();

    //    Destroy(sound, Instance.soundList[name].length);
    //}

    #endregion   

}
