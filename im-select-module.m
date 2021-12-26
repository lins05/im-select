//
//  im-select
//
//  Code are mainly borrowed from:
//
//  - https://github.com/ybian/smartim/blob/master/im-select.m
//  - https://github.com/syohex/emacs-module-test/blob/master/module-test-core.c
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

#include <assert.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "emacs-module.h"

int plugin_is_GPL_compatible;

static dispatch_queue_t q1;

void create_queue() {
    q1 = dispatch_queue_create("im-select-queue", DISPATCH_QUEUE_SERIAL);
}

static void do_switch(char *im) {
  // It's not possible to dispatch_sync into the already-blocked main thread in
  // module function
  dispatch_async(dispatch_get_main_queue(), ^{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *imId = [NSString stringWithUTF8String:im];
    free(im);
    NSDictionary *filter = [NSDictionary
        dictionaryWithObject:imId
                      forKey:(NSString *)kTISPropertyInputSourceID];
    CFArrayRef keyboards =
        TISCreateInputSourceList((CFDictionaryRef)filter, false);
    if (keyboards) {
      TISInputSourceRef selected =
          (TISInputSourceRef)CFArrayGetValueAtIndex(keyboards, 0);
      TISSelectInputSource(selected);
      CFRelease(keyboards);
    }
    [pool release];
  });
}


static char *prev_im = NULL;

static void save_prev_im() {
    char layout[128];
    memset(layout, '\0', sizeof(layout));
    TISInputSourceRef source = TISCopyCurrentKeyboardInputSource();
    // get input source id - kTISPropertyInputSourceID
    // get layout name - kTISPropertyLocalizedName
    CFStringRef layoutID = TISGetInputSourceProperty(source, kTISPropertyInputSourceID);
    CFStringGetCString(layoutID, layout, sizeof(layout), kCFStringEncodingUTF8);
    // printf("%s\n", layout);
    if (prev_im) {
        free(prev_im);
    }
    prev_im = strdup(layout);
}

static void get_current_im() {
    dispatch_block_t f1 = ^{
        save_prev_im();
    };
    // It's not possible to dispatch_sync into the already-blocked main thread
    // in a module function
    dispatch_async(dispatch_get_main_queue(), f1);
}

static const char *prev_im_placeholder = "placeholder";

static emacs_value
Fswitch_im(emacs_env *env, ptrdiff_t nargs, emacs_value args[], void *data)
{
    // printf("<<<<===>>>>\n");
    if (nargs == 0) {
        // printf("=>>> 0.0\n");
        get_current_im();
        emacs_value retval = env->make_string(env, prev_im_placeholder, strlen(prev_im_placeholder));
        return retval;
    } else {
        // printf("=>>> 1\n");
        ptrdiff_t len = 0;
        emacs_value im_name = args[0];
        env->copy_string_contents(env, im_name, NULL, &len);
        // printf("=>>> 2\n");

        char *name = NULL;
        if (len == 0) {
            return env->intern(env, "nil");
        }
        // printf("=>>> 3\n");

        name = malloc(len);
        env->copy_string_contents(env, im_name, name, &len);
        if (strcmp(name, prev_im_placeholder) == 0) {
            if (!prev_im) {
                return env->intern(env, "nil");
            }
            free(name);
            name = strdup(prev_im);
        }
        // printf("now doing switch: %s!\n", name);
        do_switch(name);
        return env->intern(env, "t");
    }
}

static void
bind_function(emacs_env *env, const char *name, emacs_value Sfun)
{
	emacs_value Qfset = env->intern(env, "fset");
	emacs_value Qsym = env->intern(env, name);
	emacs_value args[] = { Qsym, Sfun };

	env->funcall(env, Qfset, 2, args);
}

static void
provide(emacs_env *env, const char *feature)
{
	emacs_value Qfeat = env->intern(env, feature);
	emacs_value Qprovide = env->intern (env, "provide");
	emacs_value args[] = { Qfeat };

	env->funcall(env, Qprovide, 1, args);
}

int
emacs_module_init(struct emacs_runtime *ert)
{
	emacs_env *env = ert->get_environment(ert);

#define DEFUN(lsym, csym, amin, amax, doc, data) \
	bind_function (env, lsym, env->make_function(env, amin, amax, csym, doc, data))

	DEFUN("osx-im-select", Fswitch_im, 0, 1, "Switch the input method", NULL);
#undef DEFUN

	provide(env, "osx-im-select");
    // create_queue();
	return 0;
}
